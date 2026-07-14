// =============================================================================
//  Global search - one search box for the whole app
// -----------------------------------------------------------------------------
//  Opened from the Home search icon. Searches across our own content - products,
//  the Read Next library, Can I? answers, symptoms - plus app tools & sections,
//  and jumps straight to the right screen. No backend; all local data.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/can_i_data.dart';
import '../data/product_data.dart';
import '../data/read_next_data.dart';
import '../data/symptom_data.dart';
import '../localization/app_language.dart';
import '../models/can_i_entry.dart';
import '../models/symptom.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'bump_journey_screen.dart';
import 'calendar_screen.dart';
import 'can_i_screen.dart';
import 'community_screen.dart';
import 'garbh_screen.dart';
import 'journal_screen.dart';
import 'journey_map_screen.dart';
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

void showGlobalSearch(BuildContext context, PregnancyController controller) {
  showSearch<void>(context: context, delegate: _GlobalSearchDelegate(controller));
}

/// A tool / section the search can jump to.
class _Dest {
  const _Dest(this.label, this.keys, this.icon, this.build);
  final String label;
  final List<String> keys; // lowercase synonyms
  final IconData icon;
  final Widget Function(PregnancyController) build;
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
        _Dest(s.pclTitle, const ['checklist', 'product checklist', 'shopping'],
            Icons.checklist_rounded, (c) => ProductChecklistScreen(controller: c)),
        _Dest(s.bumpTitle, const ['bump', 'belly', 'photo', 'journey'],
            Icons.pregnant_woman_rounded, (c) => BumpJourneyScreen(controller: c)),
        _Dest(s.jrTitle, const ['journal', 'memory', 'diary', 'note'],
            Icons.menu_book_rounded, (c) => JournalScreen(controller: c)),
        _Dest(s.garbhToolTitle, const ['garbh', 'sanskar', 'ritual', 'spiritual'],
            Icons.spa_rounded, (c) => GarbhScreen(controller: c)),
        _Dest(s.sprToolTitle, const ['spiritual', 'reading', 'faith', 'religion'],
            Icons.auto_stories_rounded, (c) => SpiritualReadingScreen(controller: c)),
        _Dest(s.toolCanI, const ['can i', 'safe', 'eat', 'food', 'drink'],
            Icons.help_outline_rounded, (c) => CanIScreen(controller: c)),
        _Dest(s.symToolTitle, const ['symptom', 'nausea', 'pain', 'relief'],
            Icons.healing_rounded, (c) => SymptomCompanionScreen(controller: c)),
        _Dest(s.vedaToolTitle, const ['veda', 'ask', 'assistant', 'help'],
            Icons.auto_awesome_rounded, (c) => AskVedaScreen(controller: c)),
        _Dest(s.babyMovementTracker, const ['kick', 'movement', 'counter'],
            Icons.favorite_rounded, (c) => BabyMovementScreen(controller: c)),
        _Dest(s.hbName, const ['hospital', 'bag', 'pack', 'labour'],
            Icons.luggage_rounded, (c) => ReadyForBirthScreen(controller: c)),
        _Dest(s.tsrTitle, const ['scan', 'ultrasound', 'nt', 'anomaly', 'growth', 'doppler'],
            Icons.fact_check_rounded, (c) => TestsScansReportsScreen(controller: c)),
        _Dest(s.ddcToolTitle, const ['due date', 'calculator', 'edd'],
            Icons.calendar_month_rounded,
            (c) => DueDateCalculatorScreen(controller: c)),
        _Dest(s.medTitle, const ['medicine', 'medication', 'supplement', 'pill'],
            Icons.medication_rounded, (c) => MedicineTrackerScreen(controller: c)),
        _Dest(s.tsrTitle, const ['report', 'test', 'result', 'blood', 'finding', 'condition'],
            Icons.description_rounded, (c) => TestsScansReportsScreen(controller: c)),
        _Dest(s.tabCalendar, const ['calendar', 'date', 'event', 'reminder'],
            Icons.calendar_today_rounded, (c) => CalendarScreen(controller: c)),
        _Dest(s.tabCommunity, const ['community', 'mom', 'group', 'post'],
            Icons.groups_rounded, (c) => CommunityScreen(controller: c)),
      ];

  Widget _results(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final q = query.trim();
    if (q.isEmpty) {
      return _hint(s);
    }
    final lc = q.toLowerCase();

    final dests = _destinations(s)
        .where((d) =>
            d.label.toLowerCase().contains(lc) ||
            d.keys.any((k) => k.contains(lc)))
        .take(8)
        .toList();
    final products = productSearch(q).take(6).toList();
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
              onTap: () => _go(context, d.build(controller)),
            ),
        ],
        if (products.isNotEmpty) ...[
          _header(s.searchProducts),
          for (final p in products)
            ListTile(
              leading: _leadEmoji(p.emoji),
              title: Text(p.name),
              subtitle: Text('${p.price} · ${p.summary}',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => _go(
                  context, ProductDetailScreen(product: p, controller: controller)),
            ),
        ],
        if (reads.isNotEmpty) ...[
          _header(s.searchReads),
          for (final r in reads)
            ListTile(
              leading: _leadEmoji(r.emoji),
              title: Text(r.title),
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
              onTap: () =>
                  _go(context, SymptomCompanionScreen(controller: controller)),
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

  Widget _leadIcon(IconData icon) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppTheme.primary500.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: AppTheme.primary600),
      );

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(t.toUpperCase(),
            style: GoogleFonts.manrope(
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
                style: GoogleFonts.manrope(
                    fontSize: 14, height: 1.5, color: AppTheme.neutral500)),
          ]),
        ),
      );
}
