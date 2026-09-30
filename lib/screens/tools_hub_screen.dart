// =============================================================================
//  ToolsHubScreen - the "Tools" tab (Warm Nest)
// -----------------------------------------------------------------------------
//  The calm toolbox: the Pregnancy Journey map as the hero, then a grid of all
//  the gentle helpers - Baby Movement, Weight, Kegel, Contractions, Hospital
//  Bag, Medication & Supplements, Understanding Your Report, Can I?. Lives in
//  the bottom pill (replacing the Sanskar slot, which moved to Home).
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/family_profile.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../widgets/profile_ask_strip.dart';
import 'belly_skin/bump_ritual_screen.dart';
import 'can_i_screen.dart';
import 'father/father_journal_screen.dart';
// father_stories_screen parked - the "Stories, Fables & Mythology" tile was
// removed from Tools. Kept commented for revert.
// import 'father/father_stories_screen.dart';
import 'garbh_screen.dart';
import '../services/surface_router.dart' show screenForSurface;
import 'journal_screen.dart';
import 'journey_map_screen.dart';
import 'read_next_screen.dart';
import 'reminders_screen.dart';
// Old "Understanding Your Report" screen - merged into TestsScansReportsScreen.
// Kept commented for revert.
// import 'report_screen.dart';
import 'package:flutter/foundation.dart';

import '../brand/brand_preview_screen.dart';
import 'brand_showcase_screen.dart';
import 'care_partner/care_debug_screen.dart';
import '../brand/brand_models.dart';
import '../brand/launch_hub_screen.dart';
import 'product_guide/product_guide_hub_screen.dart';
import 'prepare/prepare_hub_screen.dart';
import 'tools/ask_veda_screen.dart';
import 'tools/baby_movement_screen.dart';
import 'tools/contraction_tracker_screen.dart';
import 'tools/due_date_calculator_screen.dart';
// Hospital Bag retired in favour of the "Ready for Birth" redesign (kept for
// revert). import 'tools/hospital_bag_screen.dart';
import 'tools/ready_for_birth_screen.dart';
import 'tools/kegel_care_screen.dart';
import 'tools/medicine_tracker_screen.dart';
import 'tools/product_checklist_screen.dart';
// Old "Scans & Care" screen - merged into TestsScansReportsScreen. Kept
// commented for revert.
// import 'tools/scans_appointments_screen.dart';
import 'tools/spiritual_reading_screen.dart';
import 'tools/tests_scans_reports_screen.dart';
import 'tools/symptom_companion_screen.dart';
import 'tools/weight_tracker_screen.dart';
import '../theme/pv_fonts.dart';
import 'learn/pv_learn_screen.dart';
import '../services/life_stage_store.dart';
import 'doors/pv_door_screen.dart' show pvDoorScreenForBracket;
import '../data/doors/pv_door_symptoms.dart' show kSymptomsBracketId;
import '../data/doors/pv_door_labour.dart' show kLabourSurfaceBirthPlan;
import '../widgets/global_ask_fab.dart' show kAskVedaRoute;
import '../widgets/pv_feedback.dart';
import 'doors/pv_list_row.dart';
import 'doors/pv_live_search.dart';
import 'pregnancy/birth_plan_screen.dart';
import 'products/pv_store_chrome.dart' show pvStorePalette;
import 'v2/v2_palette.dart';
import 'pregnancy/preg_chrome.dart';

// =============================================================================
//  THE LIST — 2026-09-29, the structure pass
// -----------------------------------------------------------------------------
//  The pregnancy gap analysis, "Tools tab · Clean the list: her tools only,
//  grouped" (P2): 24 tiles in the older plum grid mixed her tools with sponsor
//  showcases ("Launches", "Brand Studio") and the father's journal, and the
//  birth plan was missing. What to Expect's Tools tab is short and plain, one
//  line per tool.
//
//  So this is the TTC Tools tab's shape (the user's screenshot, and
//  `ttc_tools_screen.dart`): a large title and one line, "Find a tool", then
//  unboxed rows (`PvRowGroup` + `PvListRow`) under eyebrows, each tool's glyph
//  in its group's tint. The groups are the PDF's three, Track · Get ready ·
//  Keep, plus the TTC tab's "Plan and check" as Check and ask, because Is it
//  safe? and Ask Veda fit none of the three and a tool with no group is a
//  tool with no home.
//
//  WHERE THE REST WENT, NOTHING DELETED:
//    Learn, Read recommendations  the Learn tab (the bar's second slot)
//    Prepare                      More › All programmes and sessions
//    Product Guide                the Products tab (the guide lives in it)
//    Journey map hero             More › Your journey
//    Launches, Brand Studio       off her list (sponsor showcases); the debug
//                                 workbenches stay in debug builds only
//    Father's Journal             his side (the partner's Journal tab)
//  The grid is `ToolsHubScreenClassic` below, byte for byte, for revert.
//
//  Mobbin: What to Expect's Tools list (the PDF's reference); Apple Health
//  Search, a large title then the list (AH-SEARCH,
//  https://mobbin.com/screens/cd8919aa-c470-48b8-8716-54343395eab2), the
//  reference the TTC Tools tab was built to.
// =============================================================================

/// One group of tools: an eyebrow, a tint, and its rows.
class _ToolGroup {
  const _ToolGroup(this.title, this.hue, this.tools);
  final String title;
  final double hue;
  final List<_Tool> tools;
}

class ToolsHubScreen extends StatefulWidget {
  const ToolsHubScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends State<ToolsHubScreen> {
  final PvLiveSearch _search = PvLiveSearch();

  PregnancyController get controller => widget.controller;

  static const double _g = 18;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(String route, Widget Function() b) {
    pvCommitFeedback();
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: route),
      builder: (_) => b(),
    ));
  }

  List<_ToolGroup> _groups(S s) => [
        _ToolGroup('Track', 206, [
          _Tool(s.babyMovementTracker, Icons.favorite_border_rounded,
              AppTheme.secondary500,
              () => _open('tools/movement', () => BabyMovementScreen(controller: controller)),
              line: "Count kicks and get to know your baby's pattern",
              priority: PregPriority.babyDevelopment),
          _Tool(s.toolWeightTitle, Icons.monitor_weight_outlined,
              AppTheme.tertiary500,
              () => _open('tools/weight', () => WeightTrackerScreen(controller: controller)),
              line: 'Log your weight and see a healthy range for you',
              priority: PregPriority.nutrition),
          _Tool(s.medTitle, Icons.medication_outlined, const Color(0xFF4F7A52),
              () => _open('tools/medicines', () => MedicineTrackerScreen(controller: controller)),
              line: 'What your doctor prescribed, with reminders',
              priority: PregPriority.symptoms),
          _Tool(s.symToolTitle, Icons.healing_outlined, const Color(0xFF4A7BC8),
              // The Symptoms door (2026-09-23), as the grid opened it.
              () => _open('bracket/symptoms', () =>
                  pvDoorScreenForBracket(kSymptomsBracketId, controller) ??
                  SymptomCompanionScreen(controller: controller)),
              line: "What's normal, what helps, and when to call",
              priority: PregPriority.symptoms),
          _Tool(s.toolKegelTitle, Icons.self_improvement_rounded,
              AppTheme.secondary400,
              () => _open('tools/kegel', () => KegelCareScreen(controller: controller)),
              line: 'A few minutes a day for your pelvic floor',
              priority: PregPriority.fitness),
          _Tool(s.tsrTitle, Icons.fact_check_outlined, AppTheme.primary500,
              () => _open('tools/tests_scans', () => TestsScansReportsScreen(controller: controller)),
              line: 'Your scans and reports, and what each one checks',
              priority: PregPriority.symptoms),
          _Tool(s.rmdTitle, Icons.notifications_none_rounded,
              const Color(0xFFE0921C),
              () => _open('tools/reminders', () => RemindersScreen(controller: controller)),
              line: 'What we remind you about, and when'),
        ]),
        _ToolGroup('Get ready', 28, [
          _Tool(s.hbName, Icons.luggage_outlined, AppTheme.tertiary400,
              () => _open('tools/hospital_bag', () => ReadyForBirthScreen(controller: controller)),
              line: 'What to pack for you, your baby and your partner',
              priority: PregPriority.birthPrep),
          // Added by the gap analysis: the birth plan was built for the Labour
          // door and never listed here.
          _Tool('Birth plan', Icons.edit_note_rounded, const Color(0xFFB0654A),
              () => _open(kLabourSurfaceBirthPlan, () => BirthPlanScreen(pregnancy: controller)),
              line: 'What you would like on the day, to share with your doctor',
              priority: PregPriority.birthPrep),
          _Tool(s.toolContractionTitle, Icons.timer_outlined, AppTheme.primary400,
              () => _open('tools/contractions', () => ContractionTrackerScreen(controller: controller)),
              line: 'Time your contractions and see when to go in',
              priority: PregPriority.birthPrep),
          _Tool(s.ddcToolTitle, Icons.calendar_month_outlined, AppTheme.primary500,
              () => _open('tools/due_date', () => DueDateCalculatorScreen(controller: controller)),
              line: 'Work out your due date, or update it after a scan',
              staleDueDate: controller.dueDateMayBeStale),
          _Tool(s.pclTitle, Icons.checklist_rounded, const Color(0xFF3E9A8C),
              () => _open('tools/product_checklist', () => ProductChecklistScreen(controller: controller)),
              line: 'What you really need before the baby comes',
              priority: PregPriority.birthPrep),
        ]),
        _ToolGroup('Keep', 330, [
          _Tool(s.jrTitle, Icons.menu_book_outlined, const Color(0xFF8A6BBF),
              () => _open('journal', () => JournalScreen(controller: controller)),
              line: 'Write to yourself, or to your baby'),
          _Tool(s.bumpTitle, Icons.pregnant_woman_rounded, const Color(0xFFCB6F94),
              () => _open('tools/bump', () => BumpRitualScreen(controller: controller)),
              line: 'A photo of your bump, week by week'),
          _Tool(s.garbhToolTitle, Icons.spa_outlined, const Color(0xFFBE9C4E),
              () => _open('garbh_daily', () =>
                  screenForSurface('garbh_daily', controller, controller.language) ??
                  GarbhScreen(controller: controller)),
              line: "Today's practice: a story, a sound, a quiet minute",
              priority: PregPriority.anxiety),
          _Tool(s.sprToolTitle, Icons.auto_stories_outlined, const Color(0xFF9A7BB5),
              () => _open('tools/spiritual_reading', () => SpiritualReadingScreen(controller: controller)),
              line: 'Short readings to hear, or to read aloud',
              priority: PregPriority.anxiety),
        ]),
        _ToolGroup('Check and ask', 268, [
          // "Is it safe?" is what the door and the home call it; the string
          // table's "Can I?" is its older name. Kept for revert: s.toolCanI.
          _Tool('Is it safe?', Icons.help_outline_rounded, AppTheme.secondary600,
              () => _open('can_i', () => CanIScreen(controller: controller)),
              line: 'Food, medicines and everyday things, answered'),
          _Tool(s.vedaToolTitle, Icons.auto_awesome_outlined, AppTheme.primary600,
              () => _open(kAskVedaRoute, () => AskVedaScreen(controller: controller)),
              line: 'Ask anything, in your own words'),
        ]),
        // The two workbenches the grid carried, debug builds only, as before.
        if (kDebugMode)
          _ToolGroup('Developer', 0, [
            _Tool('Brand Studio (debug)', Icons.science_outlined,
                const Color(0xFFD92D20),
                () => _open('debug/brand', () => BrandPreviewScreen(pregnancyWeek: controller.currentWeek)),
                line: 'Debug builds only'),
            _Tool('Care Partner (debug)', Icons.qr_code_2_rounded,
                const Color(0xFFD92D20),
                () => _open('debug/care', () => const CareDebugScreen()),
                line: 'Debug builds only'),
          ]),
      ];

  /// The doors' rule: every word she typed starts a word in the title or the
  /// line.
  bool _matches(_Tool t, String q) {
    final hay = '${t.title} ${t.line ?? ''}'
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final words = q.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((w) => w.isNotEmpty);
    return words.every((w) => hay.any((h) => h.startsWith(w)));
  }

  @override
  Widget build(BuildContext context) {
    // Listens to the profile as well as the controller, so re-ordering takes
    // effect the moment she changes what she wants help with.
    return AnimatedBuilder(
      animation: Listenable.merge([controller, FamilyProfileStore.instance, _search]),
      builder: (context, _) {
        final p = pvStorePalette;
        final s = S(controller.language);
        final groups = _groups(s);
        return PvLiveSearchScope(
          search: _search,
          child: Container(
            color: p.ground,
            child: ListView(
              // kAskFabReserve, as the grid had it: the Ask Veda button floats
              // over every tab, and the last row must clear it.
              padding: EdgeInsets.fromLTRB(
                  0, MediaQuery.of(context).padding.top + 12, 0, kAskFabReserve + 40),
              children: [
                _pad(Text(s.toolsTitle,
                    style: pvFraunces(
                        fontSize: 30, fontWeight: FontWeight.w500, height: 1.1, color: p.ink1))),
                const SizedBox(height: 6),
                _pad(PvLiveSearchWords(
                  search: _search,
                  // Kept for revert: s.toolsIntro ("Helpful companions for your
                  // journey - more arriving soon").
                  child: Text(
                      'Tools to track your pregnancy, get ready for the birth and '
                      'keep what matters. Tap one to open it. None of them are required.',
                      style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
                )),
                const SizedBox(height: 14),
                _pad(PvLiveSearchField(search: _search, p: p, hint: 'Find a tool')),
                if (_search.searching)
                  ..._results(p, groups)
                else ...[
                  for (final g in groups) ..._group(p, g),
                  // Progressive profiling, kept: whatever she picks re-sorts the
                  // rows inside each group. Under the list now, so the list leads.
                  const SizedBox(height: 22),
                  _pad(pregPrioritiesStrip(controller.language, 'tools_hub')),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: _g), child: child);

  // ignore: unused_element
  Widget _eyebrow(V2Palette p, String t) => Text(t.toUpperCase(),
      style: pvManrope(
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action));

  List<Widget> _group(V2Palette p, _ToolGroup g) => [
        const SizedBox(height: 26),
        // One ParentVeda (2026-09-30): a page section takes the one serif
        // heading; the violet caps eyebrow was a second heading style.
        // Kept for revert: _pad(_eyebrow(p, g.title)),
        _pad(PregSectionHeading(g.title)),
        const SizedBox(height: 10),
        _pad(PvRowGroup(p: p, children: [
          // LEVEL 3 personalisation, inside the group: a stable sort, every
          // tool returned, the ones serving a priority she chose first.
          for (final t in FamilyProfileStore.instance
              .orderByPregPriority(g.tools, (t) => t.priority))
            _row(p, t, g.hue),
        ])),
      ];

  Widget _row(V2Palette p, _Tool t, double hue) => PvListRow(
        p: p,
        leading: PvMarkWell(p: p, hue: hue, size: 40, icon: t.icon),
        title: t.title,
        line: t.line,
        // The one conditional line (§9.1b): her date is ours and a scan has
        // probably overtaken it. Said as an offer, on the tile she opens to
        // change it.
        meta: t.staleDueDate ? S(controller.language).ddcMayBeStale : null,
        onTap: t.onTap,
      );

  List<Widget> _results(V2Palette p, List<_ToolGroup> groups) {
    final q = _search.query;
    final hits = [
      for (final g in groups)
        for (final t in g.tools)
          if (_matches(t, q)) (t, g.hue),
    ];
    return [
      const SizedBox(height: 18),
      if (hits.isEmpty)
        _pad(Text('No tool by that name. Try a shorter word, or ask Veda.',
            style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)))
      else
        _pad(PvRowGroup(p: p, children: [
          for (final (t, hue) in hits) _row(p, t, hue),
        ])),
      const SizedBox(height: 14),
      _pad(PvLiveSearchWayOn(
        p: p,
        icon: Icons.auto_awesome_outlined,
        title: 'Ask Veda about "$q"',
        line: 'In your own words, with your week in mind.',
        onTap: () {
          _search.focus.unfocus();
          _open(kAskVedaRoute, () => AskVedaScreen(controller: controller, initialQuery: q));
        },
      )),
    ];
  }
}

/// The pre-2026-09-29 grid. Kept for revert; nothing pushes it.
class ToolsHubScreenClassic extends StatelessWidget {
  const ToolsHubScreenClassic({super.key, required this.controller});
  final PregnancyController controller;

  static const List<BoxShadow> _soft = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
  ];

  @override
  Widget build(BuildContext context) {
    // Listens to the profile as well as the controller, so re-ordering takes
    // effect the moment she changes what she wants help with.
    return AnimatedBuilder(
      animation: Listenable.merge([controller, FamilyProfileStore.instance]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(controller.language);

    void open(Widget Function() b) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => b()));

    final tools = <_Tool>[
      // ⚠️ LEARN HAD NO DOOR WITH ITS NAME ON IT — 2026-09-22, the user:
      // "I can't see a Learn tab". The one catalogue of courses,
      // masterclasses, cohorts and consults was three taps down and called
      // something else: Tools → Prepare → Courses & Cohorts. A screen
      // nobody can name is a screen nobody finds. Prepare keeps its tile
      // (it still holds yoga, birthing classes and the nutrition funnel);
      // the overlap between the two is STILL-OPEN §69.9.
      // ⚠️ IT CARRIES A PRIORITY OR IT SINKS. The grid is reordered by
      // `orderByPregPriority` — tiles serving a priority she chose come
      // first — so a tile with none lands behind every tile that has one,
      // which is where Learn went on the walk (2026-09-22): added first in
      // this list and rendered fourth. Birth prep is the honest tag: the
      // catalogue's live things are birth classes, cohorts and consults.
      _Tool(
        'Learn',
        Icons.play_lesson_outlined,
        AppTheme.primary500,
        () => open(() => const PvLearnScreen(stage: LifeStage.pregnancy)),
        priority: PregPriority.birthPrep,
      ),
      // ⚠️ PREPARE LEFT THE BAR — 2026-09-17. Slot 2 became the unified store
      // (docs/PRODUCTS-AUDIT.md); the courses, consults, yoga and birthing
      // classes hub is the FIRST tile here so it is one tap further, never
      // hidden. Pushed with a back label because it was a tab root before.
      _Tool(
        s.tabPrepare,
        Icons.school_outlined,
        AppTheme.primary400,
        () => open(
          () => PrepareHubScreen(
            lang: controller.language,
            backLabel: s.toolsTab,
          ),
        ),
        priority: PregPriority.birthPrep,
      ),
      // ⚠️ THE DOOR, NOT THE LIBRARY — 2026-09-12. Found on the phone: this
      // tile still opened `GarbhScreen`, the "pick a pillar" menu the door
      // replaced, so the area had two front doors and the older one was the
      // one the Tools tab showed. Same screen as the home tile now; the
      // library stays in the file for revert.
      _Tool(
        s.garbhToolTitle,
        Icons.spa_rounded,
        const Color(0xFFBE9C4E),
        () => open(
          () =>
              screenForSurface(
                'garbh_daily',
                controller,
                controller.language,
              ) ??
              GarbhScreen(controller: controller),
        ),
        priority: PregPriority.anxiety,
      ),
      _Tool(
        s.sprToolTitle,
        Icons.auto_stories_rounded,
        const Color(0xFF9A7BB5),
        () => open(() => SpiritualReadingScreen(controller: controller)),
        priority: PregPriority.anxiety,
      ),
      _Tool(
        s.babyMovementTracker,
        Icons.favorite_rounded,
        AppTheme.secondary500,
        () => open(() => BabyMovementScreen(controller: controller)),
        priority: PregPriority.babyDevelopment,
      ),
      _Tool(
        s.bumpTitle,
        Icons.pregnant_woman_rounded,
        const Color(0xFFCB6F94),
        () => open(() => BumpRitualScreen(controller: controller)),
      ),
      _Tool(
        s.jrTitle,
        Icons.menu_book_rounded,
        const Color(0xFF8A6BBF),
        () => open(() => JournalScreen(controller: controller)),
      ),
      _Tool(
        s.rnTitle,
        Icons.local_library_rounded,
        AppTheme.secondary500,
        () => open(() => ReadNextScreen(controller: controller)),
      ),
      _Tool(
        s.toolWeightTitle,
        Icons.monitor_weight_rounded,
        AppTheme.tertiary500,
        () => open(() => WeightTrackerScreen(controller: controller)),
        priority: PregPriority.nutrition,
      ),
      _Tool(
        s.toolKegelTitle,
        Icons.self_improvement_rounded,
        AppTheme.secondary400,
        () => open(() => KegelCareScreen(controller: controller)),
        priority: PregPriority.fitness,
      ),
      _Tool(
        s.toolContractionTitle,
        Icons.timer_rounded,
        AppTheme.primary400,
        () => open(() => ContractionTrackerScreen(controller: controller)),
        priority: PregPriority.birthPrep,
      ),
      _Tool(
        s.hbName,
        Icons.luggage_rounded,
        AppTheme.tertiary400,
        () => open(() => ReadyForBirthScreen(controller: controller)),
        priority: PregPriority.birthPrep,
      ),
      _Tool(
        s.pclTitle,
        Icons.checklist_rounded,
        const Color(0xFF3E9A8C),
        () => open(() => ProductChecklistScreen(controller: controller)),
        priority: PregPriority.birthPrep,
      ),
      // Product Guide is inside the store now (the Guide's experts, ingredients
      // and studies sit on every product page). Tile kept so the word still
      // finds it; it opens the Parenting storefront.
      _Tool(
        'Product Guide',
        Icons.menu_book_outlined,
        AppTheme.primary400,
        () => open(() => const ProductGuideHubScreen()),
      ),
      // The Launch Hub's only front door. A destination is visited on purpose —
      // it is never pushed at anyone. See docs/BRAND-STUDIO.md §3.
      _Tool(
        'Launches',
        Icons.auto_awesome_outlined,
        const Color(0xFF7A4600),
        () => open(
          () => LaunchHubScreen(
            stage: BrandStage.pregnancy,
            pregnancyWeek: controller.currentWeek,
          ),
        ),
      ),
      // The guided tour of all 15 brand products. NOT debug-gated on purpose:
      // a monetization architecture nobody can see may as well not exist.
      _Tool(
        'Brand Studio',
        Icons.workspace_premium_outlined,
        const Color(0xFF6A30B6),
        () => open(
          () => BrandShowcaseScreen(pregnancyWeek: controller.currentWeek),
        ),
      ),
      // Debug-only workbench. The Brand Studio's job is to show almost nothing,
      // so this is the only way to see whether it is working at all.
      if (kDebugMode)
        _Tool(
          'Brand Studio (debug)',
          Icons.science_outlined,
          const Color(0xFFD92D20),
          () => open(
            () => BrandPreviewScreen(pregnancyWeek: controller.currentWeek),
          ),
        ),
      // Same reason as above. The Care Partner module is deliberately quiet in
      // the product, and the scan-to-attribution chain cannot be walked for
      // real until there is a Play listing — so this is the only way to see
      // whether any of it works.
      if (kDebugMode)
        _Tool(
          'Care Partner (debug)',
          Icons.qr_code_2_rounded,
          const Color(0xFFD92D20),
          () => open(() => const CareDebugScreen()),
        ),
      _Tool(
        s.medTitle,
        Icons.medication_rounded,
        const Color(0xFF4F7A52),
        () => open(() => MedicineTrackerScreen(controller: controller)),
        priority: PregPriority.symptoms,
      ),
      _Tool(
        s.rmdTitle,
        Icons.notifications_active_rounded,
        const Color(0xFFE0921C),
        () => open(() => RemindersScreen(controller: controller)),
      ),
      // Merged "Tests, Scans & Reports" (Section 16) replaces both the old
      // "Understanding Your Report" and "Scans & Care" tiles.
      _Tool(
        s.tsrTitle,
        Icons.fact_check_rounded,
        AppTheme.primary500,
        () => open(() => TestsScansReportsScreen(controller: controller)),
        priority: PregPriority.symptoms,
      ),
      // _Tool(s.rTitle, Icons.description_rounded, AppTheme.primary500,
      //     () => open(() => ReportScreen(controller: controller))),
      _Tool(
        s.toolCanI,
        Icons.help_outline_rounded,
        AppTheme.secondary600,
        () => open(() => CanIScreen(controller: controller)),
      ),
      _Tool(
        s.symToolTitle,
        Icons.healing_rounded,
        const Color(0xFF4A7BC8),
        // The Symptoms door (2026-09-23); kept for revert:
        // () => open(() => SymptomCompanionScreen(controller: controller)),
        () => open(() =>
            pvDoorScreenForBracket(kSymptomsBracketId, controller) ??
            SymptomCompanionScreen(controller: controller)),
        priority: PregPriority.symptoms,
      ),
      // Merged into "Tests, Scans & Reports" above. Kept commented for revert.
      // _Tool(s.scnToolTitle, Icons.event_note_rounded, const Color(0xFF2E9C8E),
      //     () => open(() => ScansAppointmentsScreen(controller: controller))),
      _Tool(
        s.ddcToolTitle,
        Icons.calendar_month_rounded,
        AppTheme.primary500,
        () => open(() => DueDateCalculatorScreen(controller: controller)),
        staleDueDate: controller.dueDateMayBeStale,
      ),
      _Tool(
        s.vedaToolTitle,
        Icons.auto_awesome_rounded,
        AppTheme.primary600,
        () => open(() => AskVedaScreen(controller: controller)),
      ),
      // Father's "Stories, Fables & Mythology" removed (the feature was retired
      // from the father product). Kept commented for revert.
      // _Tool('Stories, Fables & Mythology', Icons.history_edu_rounded,
      //     const Color(0xFFE0915B), () => open(() => const FatherStoriesScreen())),
      // Father's simple journal (memory / note / photo / voice) - separate store.
      _Tool(
        "Father's Journal",
        Icons.menu_book_rounded,
        const Color(0xFF2E5266),
        () => open(() => FatherJournalScreen(controller: controller)),
      ),
    ];

    return Container(
      color: AppTheme.surfaceContainer,
      child: SafeArea(
        bottom: false,
        child: ListView(
          // kAskFabReserve, not a hand-picked 110.
          //
          // The Ask Veda FAB is stacked over the whole app, so a screen that
          // does not reserve room for it has its last card covered. 110 was
          // 108px short of what the FAB actually occupies, which is why the
          // bottom tile sat underneath it. The parenting side already reserves
          // this constant in seventeen screens; the pregnancy side reserved it
          // in none.
          padding: const EdgeInsets.fromLTRB(18, 14, 18, kAskFabReserve),
          children: [
            Text(
              s.toolsTitle,
              style: pvJakarta(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.toolsIntro,
              style: pvManrope(fontSize: 13, color: AppTheme.neutral600),
            ),
            const SizedBox(height: 18),
            _journeyHero(context, s),
            // Progressive profiling, asked exactly where the answer pays off:
            // whatever she picks here re-sorts the grid directly below, so the
            // benefit is visible in the same breath as the question.
            pregPrioritiesStrip(controller.language, 'tools_hub'),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                const gap = 12.0;
                final w = (c.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    // LEVEL 3 personalization. A stable sort that returns EVERY
                    // tile: tools serving a priority she chose come first, the
                    // rest keep their original order behind them. Nothing is
                    // hidden, renamed, or moved to another screen - she still
                    // learns one Tools tab with the same 22 things in it.
                    for (final t
                        in FamilyProfileStore.instance.orderByPregPriority(
                          tools,
                          (t) => t.priority,
                        ))
                      SizedBox(width: w, child: _tile(s, t)),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 20,
                    color: AppTheme.primary500,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.toolsSupportNote,
                      style: pvManrope(
                        fontSize: 12,
                        height: 1.4,
                        color: AppTheme.primary700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _journeyHero(BuildContext context, S s) => GestureDetector(
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JourneyMapScreen(controller: controller),
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary500, AppTheme.primary700],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x292D144C),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.map_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.toolJourneyTitle,
                  style: pvJakarta(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.toolJourneySubtitle,
                  style: pvManrope(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ],
      ),
    ),
  );

  Widget _tile(S s, _Tool t) => GestureDetector(
    onTap: t.onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(t.icon, color: t.color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            t.title,
            style: pvJakarta(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary900,
            ),
          ),
          // A quiet line, only when there is something true to say.
          //
          // This is the surfacing half of §9.1b. `DueDateSource` has
          // recorded who owns her date since 2026-07-27 and nothing ever
          // read it, so a woman who counted from her last period in week six
          // and had a dating scan in week twelve kept the weaker number for
          // the rest of her pregnancy — every week card, every appointment,
          // every countdown derived from it.
          //
          // It goes HERE rather than on the home, deliberately. Nothing is
          // wrong today: the app holds one date and derives everything from
          // it consistently, so this is a correction OPPORTUNITY, not an
          // error. A banner on the home for something that is not yet wrong
          // is precisely the noise a calm product cannot afford — and this
          // is the tile she opens when she wants to change the date, which
          // is the moment the sentence is useful.
          if (t.staleDueDate) ...[
            const SizedBox(height: 6),
            Text(
              s.ddcMayBeStale,
              style: pvManrope(
                fontSize: 10.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary700,
              ),
            ),
          ],
          // "Open →" REMOVED from every tile.
          //
          // The whole card is the tap target, so the label told her nothing
          // she could not already see — and repeated ~24 times down a
          // two-column grid it became the loudest repeating element on the
          // screen, in a different accent colour each time. A card that
          // needs to say "Open" is a card that does not look tappable; the
          // fix for that is the card, not a caption. See
          // docs/DESIGN-LAYER.md §6a.
          //
          // s.openLabel is left in the string table: tools_screen.dart
          // still uses it, and it is a legitimate label elsewhere.
        ],
      ),
    ),
  );
}

class _Tool {
  const _Tool(
    this.title,
    this.icon,
    this.color,
    this.onTap, {
    this.priority,
    this.staleDueDate = false,
    this.line,
  });
  final String title;

  /// One line saying what the tool does (the list, 2026-09-29). The grid
  /// never showed one.
  final String? line;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  /// Only the Due Date Calculator sets this, and only when the controller says
  /// her date is ours and a scan has probably overtaken it.
  ///
  /// A bool on the tile rather than a general "subtitle" slot: there is exactly
  /// one thing in this hub that has something conditional to say, and a generic
  /// field would invite a second and a third until every tile carried a line.
  final bool staleDueDate;

  /// Which parenting priority this tool serves, if any. Used ONLY to float a
  /// tool she asked for help with nearer the top. Tools with no priority, and
  /// tools whose priority she did not choose, keep their original order behind
  /// the boosted ones - nothing is ever removed or moved to another screen.
  final PregPriority? priority;
}
