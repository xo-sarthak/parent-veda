// =============================================================================
//  Global search - one search box for the whole app
// -----------------------------------------------------------------------------
//  Opened from the Home search icon. Searches across our own content - products,
//  the Read Next library, Can I? answers, symptoms - plus app tools & sections,
//  and jumps straight to the right screen. No backend; all local data.
// =============================================================================

import 'package:flutter/material.dart';
import '../brand/pee_safe/pee_safe_brand.dart' show kPeeSafeDemo;
import '../brand/pee_safe/pee_safe_recovery_kit_screen.dart' show PeeSafeRecoveryKitScreen;
import '../ask_veda/ask_veda_mark.dart';

import '../data/can_i_data.dart';
// Kept for revert (seed search retired 2026-10-28): import '../data/product_data.dart';
import '../data/read_next_data.dart';
import '../data/symptom_data.dart';
import '../localization/app_language.dart';
import '../models/can_i_entry.dart';
import '../models/symptom.dart';
import '../services/pregnancy_controller.dart';
import '../services/pv_catalog_store.dart';
import 'products/pv_product_screen.dart';
import '../theme/app_theme.dart';
import 'belly_skin/bump_ritual_screen.dart';
import 'calendar_screen.dart';
import 'can_i_screen.dart';
// import 'community_screen.dart'; // held back with the community, kept for revert
import 'community/community_chrome.dart' show openCommunity;
// Kept for revert (C1: the Garbh row opens the door now): import 'garbh_screen.dart';
import 'journal_screen.dart';
import 'journey_map_screen.dart';
import 'nutrition/door/shopping_list_screen.dart';
import 'products_screen.dart';
import 'read_next_screen.dart';
// Old "Understanding Your Report" screen - merged into TestsScansReportsScreen.
// Kept commented for revert.
// import 'report_screen.dart';
import 'tools/ask_veda_screen.dart';
import 'tools/baby_movement_screen.dart';
import 'tools/due_date_calculator_screen.dart';
// Hospital Bag retired in favour of the "Ready for Birth" redesign (kept for
// revert). import 'tools/hospital_bag_screen.dart';
import 'tools/ready_for_birth_screen.dart';
import 'tools/medicine_tracker_screen.dart';
import 'tools/product_checklist_screen.dart';
// Old "Scans & Care" screen - merged into TestsScansReportsScreen. Kept
// commented for revert.
// import 'tools/scans_appointments_screen.dart';
import 'tools/spiritual_reading_screen.dart';
import 'tools/tests_scans_reports_screen.dart';
import 'tools/symptom_companion_screen.dart';
// C1 X4/X5 (2026-10-30): every Tools row, and his side.
import '../services/father_preview.dart';
import '../services/surface_router.dart' show screenForSurface;
import '../widgets/pv_toast.dart';
import 'tools/weight_tracker_screen.dart';
import 'tools/kegel_care_screen.dart';
import 'tools/readings_log_screen.dart';
import 'tools/contraction_tracker_screen.dart';
import 'reminders_screen.dart';
import 'pregnancy/birth_plan_screen.dart';
import 'pregnancy/preg_question_lists_sheet.dart' show showPregQuestionLists;
import 'post_pregnancy/baby_naming_home_screen.dart' show BabyNamingHomeScreen;
import 'mind_mood/mm_track_tab.dart' show MmTrackTab;
import 'doors/pv_door_router.dart' show pvDoorScreenFor;
import '../data/doors/pv_door_mind.dart' show kMindSurfaceTrack;
import '../data/doors/pv_door_nutrition.dart' show kDietSurfaceToday;
import '../data/doors/pv_door_belly_skin.dart' show kBsSurfaceChecker;
import '../data/doors/pv_door_complications.dart' show kCondSurfaceFind;
import '../data/doors/pv_door_scans.dart'
    show kScansSurfaceTimeline, kScansSurfaceReports, kScansSurfaceDecoder;
import '../theme/pv_fonts.dart';
import 'doors/pv_door_screen.dart' show pvDoorScreenForBracket;
import '../data/doors/pv_door_symptoms.dart' show kSymptomsBracketId;
import '../data/symptoms/symptom_library.dart' show symptomById;
import 'symptoms/door/symptoms_today_body.dart' show openSymptomRead;

void showGlobalSearch(BuildContext context, PregnancyController controller) {
  showSearch<void>(context: context, delegate: _GlobalSearchDelegate(controller));
}

/// A tool / section the search can jump to.
class _Dest {
  const _Dest(this.label, this.keys, this.icon, this.build, {this.open, this.hers = false});
  final String label;
  final List<String> keys; // lowercase synonyms
  final IconData icon;
  // Nullable since 2026-10-28: a destination that pushes itself (the
  // community names its own route) passes [open] instead.
  final Widget Function(PregnancyController)? build;
  final void Function(BuildContext)? open;

  /// Hers alone on his side (C1 X5, 2026-10-30): the rows his Tools tab
  /// leaves off (Check in, Track, Records, the due date, her journal and
  /// bump, Find a condition). In the father preview search leaves them off
  /// too, as his Tools tab does.
  final bool hers;
}

class _GlobalSearchDelegate extends SearchDelegate<void> {
  _GlobalSearchDelegate(this.controller);
  final PregnancyController controller;

  @override
  String get searchFieldLabel => S(controller.language).searchHint;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  void _go(BuildContext context, Widget screen) {
    close(context, null);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  List<_Dest> _destinations(S s) => [
        _Dest(s.toolJourneyTitle, const ['journey', 'map', 'trail', 'week'],
            Icons.map_rounded, (c) => JourneyMapScreen(controller: c)),
        _Dest(s.navProducts, const ['product', 'shop', 'buy', 'store'],
            Icons.shopping_bag_rounded, (c) => ProductsScreen(controller: c)),
        // P4 S4 (2026-10-28): "shopping" found the baby Product checklist; it
        // means the food list now. Kept for revert:
        //   _Dest(s.pclTitle, const ['checklist', 'product checklist', 'shopping'], ...
        _Dest(s.pclTitle, const ['checklist', 'product checklist', 'baby things', 'what to buy'],
            Icons.checklist_rounded, (c) => ProductChecklistScreen(controller: c)),
        _Dest('Shopping list', const ['shopping', 'shopping list', 'grocery', 'groceries', 'ingredients'],
            Icons.shopping_basket_rounded, (_) => const ShoppingListScreen()),
        _Dest(s.bumpTitle, const ['bump', 'belly', 'photo', 'journey'],
            Icons.pregnant_woman_rounded, (c) => BumpRitualScreen(controller: c),
            hers: true),
        _Dest(s.jrTitle, const ['journal', 'memory', 'diary', 'note'],
            Icons.menu_book_rounded, (c) => JournalScreen(controller: c),
            hers: true),
        // C1 (found listing the rows): this opened the retired pillar menu,
        // which M7 says the Garbh Sanskar row must never open. It opens the
        // door now, as the Tools row does, or says why not. Kept for revert:
        //   _Dest(s.garbhToolTitle, ..., (c) => GarbhScreen(controller: c)),
        _Dest(s.garbhToolTitle, const ['garbh', 'sanskar', 'ritual', 'spiritual'],
            Icons.spa_rounded, null, open: (ctx) {
          final w = screenForSurface('garbh_daily', controller, controller.language);
          if (w == null) {
            pvToast(ctx, 'Garbh Sanskar could not open just now. Its card on your home opens it too.');
            return;
          }
          Navigator.of(ctx).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'garbh_daily'), builder: (_) => w));
        }),
        _Dest(s.sprToolTitle, const ['spiritual', 'reading', 'faith', 'religion'],
            Icons.auto_stories_rounded, (c) => SpiritualReadingScreen(controller: c)),
        // One name per tool (C1): the Tools row's "Is it safe?", with the
        // older "Can I" kept as a word to find it by. Kept for revert:
        // _Dest(s.toolCanI, const ['can i', 'safe', 'eat', 'food', 'drink'], ...
        _Dest('Is it safe?', const ['can i', 'safe', 'eat', 'food', 'drink'],
            Icons.help_outline_rounded, (c) => CanIScreen(controller: c)),
        // One name per tool (C1): the Tools row's. Kept for revert: s.symToolTitle.
        _Dest('Symptoms today', const ['symptom', 'nausea', 'pain', 'relief'],
            // The Symptoms door (2026-09-23); the companion kept for revert.
            Icons.healing_rounded, (c) => pvDoorScreenForBracket(kSymptomsBracketId, c) ?? SymptomCompanionScreen(controller: c),
            hers: true),
        _Dest(s.vedaToolTitle, const ['veda', 'ask', 'assistant', 'help'],
            Icons.auto_awesome_rounded, (c) => AskVedaScreen(controller: c)),
        _Dest(s.babyMovementTracker, const ['kick', 'movement', 'counter'],
            Icons.favorite_rounded, (c) => BabyMovementScreen(controller: c),
            hers: true),
        // One name per tool (P4): "Hospital bag". Kept for revert: s.hbName.
        _Dest('Hospital bag', const ['hospital', 'bag', 'pack', 'labour'],
            Icons.luggage_rounded, (c) => ReadyForBirthScreen(controller: c)),
        // Pee Safe demo: the recovery kit, as its Tools row (sponsored).
        if (kPeeSafeDemo)
          _Dest('Recovery kit', const ['recovery', 'kit', 'pads', 'postpartum', 'peri', 'pee safe'],
              Icons.checklist_rounded, (_) => const PeeSafeRecoveryKitScreen(), hers: true),
        // ONE ENTRY (P1, 2026-10-28): the library was listed twice under one
        // title, so search showed it twice. Both keyword lists now sit on the
        // one row. Kept for revert: a second _Dest(s.tsrTitle, ['report',
        // 'test', 'result', 'blood', 'finding', 'condition'],
        // Icons.description_rounded, ...) below the medicines row.
        _Dest(s.tsrTitle, const ['scan', 'ultrasound', 'nt', 'anomaly', 'growth', 'doppler',
            'report', 'test', 'result', 'blood', 'finding', 'condition'],
            Icons.fact_check_rounded, (c) => TestsScansReportsScreen(controller: c),
            hers: true),
        _Dest(s.ddcToolTitle, const ['due date', 'calculator', 'edd'],
            Icons.calendar_month_rounded,
            (c) => DueDateCalculatorScreen(controller: c),
            hers: true),
        _Dest(s.medTitle, const ['medicine', 'medication', 'supplement', 'pill'],
            Icons.medication_rounded, (c) => MedicineTrackerScreen(controller: c),
            hers: true),
        _Dest(s.tabCalendar, const ['calendar', 'date', 'event', 'reminder'],
            Icons.calendar_today_rounded, (c) => CalendarScreen(controller: c),
            hers: true),
        // X4 (C1, 2026-10-30): every Tools row is found here. Movement was
        // listed and Weight and Kegel were not, nor these others.
        // test/preg_c1_tools_test.dart searches every row by its title.
        _Dest(s.toolWeightTitle, const ['weight', 'weigh', 'kg', 'bmi'],
            Icons.monitor_weight_rounded, (c) => WeightTrackerScreen(controller: c),
            hers: true),
        _Dest(s.toolKegelTitle, const ['kegel', 'pelvic floor', 'pelvic'],
            Icons.self_improvement_rounded, (c) => KegelCareScreen(controller: c),
            hers: true),
        _Dest('Blood pressure & sugar', const ['blood pressure', 'bp', 'sugar', 'glucose', 'readings'],
            Icons.monitor_heart_rounded, (c) => ReadingsLogScreen(controller: c),
            hers: true),
        _Dest(s.rmdTitle, const ['reminder', 'remind', 'alarm'],
            Icons.notifications_none_rounded, (c) => RemindersScreen(controller: c),
            hers: true),
        _Dest('Mood check-in', const ['mood', 'feel', 'feeling', 'worry'],
            Icons.sentiment_satisfied_rounded,
            (c) => pvDoorScreenFor(kMindSurfaceTrack, c) ?? const MmTrackTab(),
            hers: true),
        _Dest('Your plate today', const ['plate', 'water', 'diet today', 'eat today'],
            Icons.restaurant_rounded,
            (c) => pvDoorScreenFor(kDietSurfaceToday, c) ?? const SizedBox.shrink(),
            hers: true),
        _Dest('Birth plan', const ['birth plan', 'birth preferences', 'labour plan'],
            Icons.edit_note_rounded, (c) => BirthPlanScreen(pregnancy: c)),
        _Dest('Contraction timer', const ['contraction', 'labour', 'timer'],
            Icons.timer_rounded, (c) => ContractionTrackerScreen(controller: c)),
        _Dest('Baby names', const ['name', 'names', 'baby name'],
            Icons.badge_rounded, (_) => const BabyNamingHomeScreen(afterLossNote: true)),
        _Dest('Find a condition', const ['condition', 'diabetes', 'thyroid', 'bp'],
            Icons.manage_search_rounded,
            (c) => pvDoorScreenFor(kCondSurfaceFind, c) ?? const SizedBox.shrink(),
            hers: true),
        _Dest('Ingredient checker', const ['ingredient', 'cream', 'skincare', 'retinol', 'face wash'],
            Icons.spa_rounded,
            (c) => pvDoorScreenFor(kBsSurfaceChecker, c) ?? const SizedBox.shrink()),
        _Dest('My scans', const ['scan', 'scans', 'ultrasound', 'timeline'],
            Icons.timeline_rounded,
            (c) => pvDoorScreenFor(kScansSurfaceTimeline, c) ?? const SizedBox.shrink(),
            hers: true),
        _Dest('My reports', const ['report', 'reports', 'locker', 'documents'],
            Icons.folder_rounded,
            (c) => pvDoorScreenFor(kScansSurfaceReports, c) ?? const SizedBox.shrink(),
            hers: true),
        _Dest('Report decoder', const ['decoder', 'report', 'what does my report mean'],
            Icons.search_rounded,
            (c) => pvDoorScreenFor(kScansSurfaceDecoder, c) ?? const SizedBox.shrink(),
            hers: true),
        _Dest('Questions for your doctor', const ['question', 'questions', 'what to ask', 'checklist'],
            Icons.help_center_rounded, null,
            open: (ctx) => showPregQuestionLists(ctx, controller),
            hers: true),
        // Held back with the community (2026-09-29, pregnancy gap analysis:
        // "comment out the tab and every entry point"). Kept for revert:
        // _Dest(s.tabCommunity, const ['community', 'mom', 'group', 'post'],
        //     Icons.groups_rounded, (c) => CommunityScreen(controller: c)),
        // Re-enabled 2026-10-28 for the new community (lib/screens/community).
        _Dest(s.tabCommunity, const ['community', 'mom', 'group', 'post'],
            Icons.groups_rounded, null, open: (ctx) => openCommunity(ctx)),
      ];

  Widget _results(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final q = query.trim();
    if (q.isEmpty) {
      return _hint(s);
    }
    final lc = q.toLowerCase();

    final him = FatherPreview.instance.on;
    final dests = _destinations(s)
        .where((d) => !(him && d.hers))
        .where((d) =>
            d.label.toLowerCase().contains(lc) ||
            d.keys.any((k) => k.contains(lc)))
        // Kept for revert (C1): .take(8). Every Tools row is a destination
        // now, so a word like "report" names more than eight; none is cut.
        .take(12)
        .toList();
    // The live store, not the seed (2026-10-28, the user: "no fake
    // situations"). Real products first; a Coming soon card only when
    // nothing real matches. Kept for revert:
    //   final products = productSearch(q).take(6).toList();
    final hits = PvCatalogStore.instance.search(q).all;
    final products = [
      ...hits.where((p) => !p.comingSoon),
      ...hits.where((p) => p.comingSoon),
    ].take(6).toList();
    final reads = readSearch(q).take(6).toList();
    final foods = _canISearch(lc, lang).take(5).toList();
    final symptoms = _symptomSearch(lc, lang).take(5).toList();

    if (dests.isEmpty &&
        products.isEmpty &&
        reads.isEmpty &&
        foods.isEmpty &&
        symptoms.isEmpty) {
      return _empty(s);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (dests.isNotEmpty) ...[
          _header(s.searchTools),
          for (final d in dests)
            ListTile(
              leading: _leadIcon(d.icon),
              title: Text(d.label),
              onTap: () {
                if (d.open case final open?) {
                  close(context, null);
                  open(context);
                } else {
                  _go(context, d.build!(controller));
                }
              },
            ),
        ],
        if (products.isNotEmpty) ...[
          _header(s.searchProducts),
          // Kept for revert: the seed row (emoji, invented price, the old
          // ProductDetailScreen facade).
          for (final p in products)
            ListTile(
              leading: _leadIcon(Icons.shopping_bag_outlined),
              title: Text(p.name),
              subtitle: Text(
                  p.comingSoon
                      ? 'Coming soon'
                      : [p.brand, p.summary].where((t) => t.isNotEmpty).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              onTap: () => _go(context, PvProductScreen(productId: p.id)),
            ),
        ],
        if (reads.isNotEmpty) ...[
          _header(s.searchReads),
          for (final r in reads)
            ListTile(
              leading: _leadEmoji(r.emoji),
              title: Text(r.title.now),
              subtitle: Text('${r.category} · ${r.readingTime}'),
              onTap: () => _go(
                  context, ReadItemScreen(item: r, controller: controller)),
            ),
        ],
        if (foods.isNotEmpty) ...[
          _header(s.searchCanI),
          for (final e in foods)
            ListTile(
              leading: _leadIcon(Icons.help_outline_rounded),
              title: Text(e.name.of(lang)),
              subtitle: Text(e.short.of(lang),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => _go(context, CanIScreen(controller: controller)),
            ),
        ],
        if (symptoms.isNotEmpty) ...[
          _header(s.searchSymptoms),
          for (final x in symptoms)
            ListTile(
              leading: _leadIcon(Icons.healing_rounded),
              title: Text(x.name.of(lang)),
              // A named symptom opens ITS page in the one reader, not the
              // companion's front door (2026-09-23).
              onTap: () => switch (symptomById(x.id)) {
                final sym? => openSymptomRead(context, sym, controller),
                null => _go(context, SymptomCompanionScreen(controller: controller)),
              },
            ),
        ],
      ],
    );
  }

  Iterable<CanIEntry> _canISearch(String lc, AppLanguage lang) {
    if (lc.length < 2) return const [];
    return kCanIEntries.where((e) =>
        e.name.of(lang).toLowerCase().contains(lc) ||
        e.id.replaceAll('_', ' ').contains(lc) ||
        e.aliases.any((a) => a.toLowerCase().contains(lc)));
  }

  Iterable<Symptom> _symptomSearch(String lc, AppLanguage lang) {
    if (lc.length < 2) return const [];
    return kSymptoms.where((x) =>
        x.name.of(lang).toLowerCase().contains(lc) ||
        x.keywords.any((k) => k.contains(lc)));
  }

  Widget _leadEmoji(String emoji) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12)),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      );

  // The Ask Veda destination draws its mark (2026-10-24); it is the one
  // destination with the sparkle, so the icon picks it out.
  Widget _leadIcon(IconData icon) => icon == Icons.auto_awesome_rounded
      ? const AskVedaMark(size: 40)
      : Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppTheme.neutral900.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: AppTheme.neutral900),
      );

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(t.toUpperCase(),
            style: pvManrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppTheme.neutral500)),
      );

  Widget _hint(S s) => _centered(Icons.search_rounded, s.searchEmptyHint);
  Widget _empty(S s) => _centered(Icons.sentiment_dissatisfied_rounded,
      '${s.searchNoResults} "${query.trim()}"');

  Widget _centered(IconData icon, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 42, color: AppTheme.neutral300),
            const SizedBox(height: 14),
            Text(text,
                textAlign: TextAlign.center,
                style: pvManrope(
                    fontSize: 14, height: 1.5, color: AppTheme.neutral500)),
          ]),
        ),
      );
}
