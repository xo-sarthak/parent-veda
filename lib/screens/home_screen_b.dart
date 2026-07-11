// =============================================================================
//  HomeScreenB - Mother Home / Daily Moment · "Warm Nest" (Direction B)
// -----------------------------------------------------------------------------
//  The revamped daily moment from the Claude Design "Warm Nest" direction:
//    brand header → purple gradient hero (greeting · Week/Day · baby size ·
//    progress ring) → the five daily rituals as compact tiles → today's
//    affirmation → a quick-stats row.
//
//  Each ritual tile re-opens the EXISTING daily-moment module (GrowModule,
//  ReadModule, …) verbatim in a sheet, so every underlying behaviour (readers,
//  Talk composer, raga player, "keep this with me") is preserved - this screen
//  is a re-skin of the entry points, not a rewrite of the content.
//
//  Built entirely against AppTheme tokens, which already hold the Warm-Nest
//  palette (primary #6A30B6, coral #FF5A79, lavender surfaces), so no theme
//  change is needed. The previous Home (home_screen.dart) is kept intact for an
//  easy one-line revert in MainScaffold.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/garbh_data.dart';
import '../data/product_data.dart';
import '../data/scan_schedule.dart';
import '../localization/app_language.dart';
import '../models/home_day.dart';
import '../models/journal_entry.dart';
import '../models/journey_node.dart';
import '../models/medication.dart';
import '../models/product_models.dart';
import '../models/scan_appointment.dart';
import '../services/app_nav.dart';
import '../services/garbh_store.dart';
import '../services/home_content_controller.dart';
import '../services/medicine_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/reminder_store.dart';
import '../services/scans_store.dart';
import '../theme/app_theme.dart';
// The parenting app now lands on the My Child home (the old "Today" briefing,
// PostPregnancyHome, is retired from nav but kept for revert).
// import 'post_pregnancy/post_pregnancy_home.dart';
import 'post_pregnancy/my_child_screen.dart';
import 'weekly_card_stack_screen.dart';
import '../widgets/home/home_modules.dart';
// Trimester chart removed from the Today feed (kept for revert).
// import '../widgets/home/trimester_chart_card.dart';
import '../widgets/trimester_progress_bar.dart';
import '../widgets/journal/journal_create.dart';
import 'garbh_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import 'products_screen.dart';
import 'global_search.dart';
import 'read_next_screen.dart';
import 'saved_hub_screen.dart';
import 'reminders_screen.dart';
import 'tools/medicine_tracker_screen.dart';
// Old "Scans & Care" screen - merged into TestsScansReportsScreen. Kept
// commented for revert.
// import 'tools/scans_appointments_screen.dart';
import 'tools/tests_scans_reports_screen.dart';
import 'watch_learn_screen.dart';
import 'week_flow_screen.dart';

class HomeScreenB extends StatelessWidget {
  const HomeScreenB({super.key, required this.pregnancy, required this.home});

  final PregnancyController pregnancy;
  final HomeContentController home;

  // Soft shadows mirroring the design's PV.shadowSoft / tile shadow.
  static const List<BoxShadow> _softShadow = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 10, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> _tileShadow = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
  ];

  // Sage + sand accents the design uses for two ritual tiles (not in AppTheme).
  static const Color _sageBg = Color(0xFFEAF1EA);
  static const Color _sageFg = Color(0xFF4F7A52);
  static const Color _sandBg = Color(0xFFF1E8DA);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pregnancy, home]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final lang = pregnancy.language;
    final s = S(lang);

    if (pregnancy.isLoading || home.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Active day = preview day (prototype tool) or the real current day.
    final activeDay = home.previewDay ?? pregnancy.currentDay;
    final week = (((activeDay - 1) ~/ 7) + 1).clamp(4, 40);
    final snapshot = pregnancy.weekData(week)?.snapshot;
    final day = home.dayFor(activeDay, week);

    if (snapshot == null || day == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(s.noContent, textAlign: TextAlign.center),
        ),
      );
    }

    final dayOfWeek = ((activeDay - 1) % 7) + 1;
    // A one/two-line "this week" brief shown in the hero (headline → reveal).
    final hd = snapshot.weekHeadline.of(lang).trim();
    final weekSummary = hd.isNotEmpty ? hd : snapshot.reveal.of(lang).trim();

    return Container(
      color: AppTheme.surfaceContainer, // lavender canvas (design "lav1")
      child: SafeArea(
        bottom: false,
        child: ListView(
          // Generous bottom padding so content clears the floating tab bar.
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
          children: [
            _brandHeader(context),
            const SizedBox(height: 12),
            // Temporary doorway into the new (isolated) post-pregnancy app.
            _postPregnancyDoorway(context),
            const SizedBox(height: 14),
            // ===== WEEKLY SNAPSHOT - the hero + quick shortcuts as one unit ====
            _sectionEyebrow(s.snapshotTitle),
            const SizedBox(height: 8),
            _heroCard(
              context,
              s,
              week: week,
              dayOfWeek: dayOfWeek,
              summary: weekSummary,
              greeting: s.greeting(DateTime.now().hour, pregnancy.motherName),
            ),
            const SizedBox(height: 20),
            // ===== TODAY'S PARENTING TIP - featured editorial, sits directly
            // below the Weekly Snapshot (a highlighted read, not just a card). ==
            GrowModule(day: day, lang: lang, home: home),
            const SizedBox(height: 24),
            // ===== TODAY'S JOURNEY - everything daily lives under this heading ==
            _todaysJourneyHeading(s),
            const SizedBox(height: 14),
            // Today's Video - the week's recommended Watch & Learn pick.
            TodaysVideoCard(controller: pregnancy),
            const SizedBox(height: 16),
            // "Read to your baby" folded into Garbh Sanskar › Samvad (its content
            // + customization now live there). Card removed; kept for revert.
            // ReadModule(day: day, lang: lang, home: home),
            // const SizedBox(height: 16),
            // Daily Garbh Sanskar.
            _garbhDailySection(context, lang),
            const SizedBox(height: 16),
            // Scans & Appointments + Trimester chart REMOVED from the Today feed
            // per feedback (Scans live in the Calendar / Tests-Scans-Reports; the
            // trimester progress now shows in the hero bar). Kept for revert:
            // _scansDailySection(context, lang),
            // const SizedBox(height: 16),
            // TrimesterChartCard(controller: pregnancy),
            // const SizedBox(height: 16),
            // Daily My Journal.
            _journalDailySection(context, lang),
            const SizedBox(height: 16),
            // Daily medication & supplements (shown inline).
            _medicationSection(context, lang),
            const SizedBox(height: 16),
            // Daily Reads - day-rotating articles + books, with check-off.
            DailyReadsHomeCard(controller: pregnancy, lang: lang),
            const SizedBox(height: 16),
            // Read Next moved to the Tools hub (kept commented for revert).
            // ReadNextHomeCard(controller: pregnancy, lang: lang),
            // const SizedBox(height: 16),
            // Today's product recommendation (Daily-Reads style, real images).
            _productsCarousel(context, week, lang),
          ],
        ),
      ),
    );
  }

  // --- Post-Pregnancy doorway ------------------------------------------------
  // Temporary entry into the new (isolated) parenting app. Same for mother and
  // father. The "40 weeks complete → parenting" hand-off isn't wired yet; this
  // is a preview doorway only, and the pregnancy app itself is untouched.
  Widget _postPregnancyDoorway(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const MyChildScreen(home: true),
          settings: const RouteSettings(name: 'pp/my_child'),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppTheme.primary600, AppTheme.secondary500],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x33FF5A79), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Post-Pregnancy',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Text("Baby's arrived? Step into the parenting app",
                  style: GoogleFonts.manrope(
                      fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
            ]),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
        ]),
      ),
    );
  }

  // --- brand header ----------------------------------------------------------
  Widget _brandHeader(BuildContext context) {
    final initial = pregnancy.motherName.isNotEmpty
        ? pregnancy.motherName[0].toUpperCase()
        : 'P';
    return Row(
      children: [
        Image.asset('assets/brand/pv-mark.png', height: 30),
        const SizedBox(width: 9),
        Text(
          'ParentVeda',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary600,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        // Saved hub - a bookmark right on Home, beside search.
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SavedHubScreen(controller: pregnancy))),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: const Icon(Icons.bookmark_border_rounded,
                size: 20, color: AppTheme.primary600),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => showGlobalSearch(context, pregnancy),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: const Icon(Icons.search_rounded,
                size: 20, color: AppTheme.primary600),
          ),
        ),
        const SizedBox(width: 10),
        // Profile entry - Direction B has no Profile tab, so it lives here as
        // the avatar (it holds language, My Journal, Dear Baby, products…).
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfileScreen(controller: pregnancy),
          )),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary500, AppTheme.secondary500],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // The "Weekly Snapshot" was folded into the hero's "this week" brief +
  // "View week" (see _heroCard) per the latest direction - no separate card,
  // no Baby/Mother/Health circles.

  // OLD Daily / Weekly flow toggle - replaced by the hero "this week" brief.
  // Kept (commented) for an easy revert.
  /*
  Widget _flowToggle(S s) {
    Widget seg(String label, bool selected, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary500 : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppTheme.neutral500,
                ),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: _softShadow,
      ),
      child: Row(children: [
        seg(s.flowDaily, true, () {}),
        seg(s.flowWeekly, false, () => AppNav.instance.goWeekly()),
      ]),
    );
  }
  */

  // --- gradient hero ---------------------------------------------------------
  Widget _heroCard(
    BuildContext context,
    S s, {
    required int week,
    required int dayOfWeek,
    required String summary,
    required String greeting,
  }) {
    final lang = pregnancy.language;
    // Tapping anywhere on the hero opens the weekly view (current week). The
    // weekly stack is now PUSHED (the Journey tab was replaced by "Prepare",
    // so the mother reaches the week stack from this snapshot rather than a tab).
    return GestureDetector(
      onTap: () {
        pregnancy.selectWeek(pregnancy.currentWeek);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => WeeklyCardStackScreen(controller: pregnancy)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary500, AppTheme.primary700],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -36,
              top: -36,
              child: _circle(150, Colors.white.withValues(alpha: 0.10)),
            ),
            Positioned(
              right: 30,
              bottom: -40,
              child: _circle(100, AppTheme.secondary300.withValues(alpha: 0.25)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting 🌸',
                              style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.weekDayLine(week, dayOfWeek),
                              style: GoogleFonts.fraunces(
                                fontSize: 27,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: -0.4,
                                height: 1.1,
                              ),
                            ),
                            if (summary.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  s.snapOpenWeek,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    size: 17, color: Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Horizontal TRIMESTER progress bar — replaces the old circular
                  // ring + "%" readout (applied consistently across the app).
                  const SizedBox(height: 18),
                  TrimesterProgressBar(
                    week: week,
                    daysRemaining: pregnancy.daysRemaining,
                    lang: lang,
                    onDark: true,
                  ),
                  // Baby / Mother / What's next - now part of the hero itself.
                  const SizedBox(height: 16),
                  Container(
                      height: 1, color: Colors.white.withValues(alpha: 0.18)),
                  const SizedBox(height: 14),
                  Row(children: [
                    _heroShortcut(Icons.child_care_rounded, s.ovBaby,
                        () => openWeekBabyDetail(context, pregnancy, week, lang)),
                    _heroShortcut(Icons.favorite_rounded, s.ovMother,
                        () =>
                            openWeekMotherDetail(context, pregnancy, week, lang)),
                    _heroShortcut(Icons.explore_rounded, s.wfNextSection,
                        () => openWeekWhatsNext(context, pregnancy, lang)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // A soft, glassy shortcut that lives INSIDE the hero gradient.
  Widget _heroShortcut(IconData icon, String label, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.28)),
              ),
              child: Icon(icon, size: 21, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95))),
          ]),
        ),
      );

  // Old circular progress ring — replaced by TrimesterProgressBar. Kept
  // commented for an easy revert.
  // ignore: unused_element
  Widget _progressRing(double pct, int weeksToGo) {
    return SizedBox(
      width: 74,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 62,
          height: 62,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text(
                '${(pct * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // The remaining stretch, said warmly - how much is left to go.
        Text(
          S(pregnancy.language).weeksLeftShort(weeksToGo),
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 10.5,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
      ]),
    );
  }

  // --- Weekly snapshot: eyebrow + "Today's journey" heading + 3 shortcuts ----
  Widget _sectionEyebrow(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 2),
        child: Text(text.toUpperCase(),
            style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppTheme.primary500)),
      );

  Widget _todaysJourneyHeading(S s) => Padding(
        padding: const EdgeInsets.only(left: 2, top: 2),
        child: Row(children: [
          const Icon(Icons.wb_sunny_rounded,
              size: 20, color: AppTheme.secondary500),
          const SizedBox(width: 8),
          Text(s.todaysJourney,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
        ]),
      );

  // Baby / Mother / What's next - old standalone row (now integrated INTO the
  // hero card via _heroShortcut); kept for an easy revert.
  // ignore: unused_element
  Widget _snapshotShortcuts(BuildContext context, int week, AppLanguage lang) {
    final s = S(lang);
    Widget item(IconData icon, String label, Color color, VoidCallback onTap) =>
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: _tileShadow),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 6),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
            ]),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        item(Icons.child_care_rounded, s.ovBaby, AppTheme.primary500,
            () => openWeekBabyDetail(context, pregnancy, week, lang)),
        item(Icons.favorite_rounded, s.ovMother, AppTheme.secondary500,
            () => openWeekMotherDetail(context, pregnancy, week, lang)),
        item(Icons.explore_rounded, s.wfNextSection, const Color(0xFF2E9C8E),
            () => AppNav.instance.goWeekly()),
      ]),
    );
  }

  // --- today's rituals -------------------------------------------------------
  // Old Baby/Mother shortcut cards - replaced by _snapshotShortcuts above, kept
  // for revert.
  // ignore: unused_element
  Widget _motherBabyRow(BuildContext context, int week, AppLanguage lang) {
    final s = S(lang);
    return Row(children: [
      Expanded(
        child: _mbCard(Icons.favorite_rounded, s.ovMother, AppTheme.secondary500,
            () => openWeekMotherDetail(context, pregnancy, week, lang)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _mbCard(Icons.child_care_rounded, s.ovBaby, AppTheme.primary500,
            () => openWeekBabyDetail(context, pregnancy, week, lang)),
      ),
    ]);
  }

  Widget _mbCard(IconData icon, String label, Color color, VoidCallback onTap) {
    final s = S(pregnancy.language);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _tileShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, size: 20, color: color),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 20, color: color),
          ]),
          const SizedBox(height: 12),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900)),
          const SizedBox(height: 2),
          Text(s.wfTapExplore,
              style: GoogleFonts.manrope(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }

  // Today's product recommendation - a horizontal CAROUSEL of product cards
  // (real photos, affiliate badge where relevant). Picks rotate by day.
  Widget _productsCarousel(BuildContext context, int week, AppLanguage lang) {
    final s = S(lang);
    final cd = pregnancy.currentDay;
    final picks = <Product>[];
    for (final c in recommendedCategories(week)) {
      final ps = productsForCategory(c.id);
      if (ps.isNotEmpty) picks.add(ps[cd % ps.length]);
      if (picks.length >= 8) break;
    }
    if (picks.isEmpty) return const SizedBox.shrink();
    void openShop() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductsScreen(controller: pregnancy)));
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: _tileShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppTheme.primary600, AppTheme.primary400],
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Text(s.prodSectionTitle,
                  style: GoogleFonts.fraunces(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            GestureDetector(
              onTap: openShop,
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(s.prodSeeAll,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.white),
              ]),
            ),
          ]),
        ),
        SizedBox(
          height: 226,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 14, 6, 16),
            children: [for (final p in picks) _productCarouselCard(context, p)],
          ),
        ),
      ]),
    );
  }

  // A single product card in the carousel: photo + (affiliate badge) + name +
  // price. Tap opens the product page (where the buy actions live).
  Widget _productCarouselCard(BuildContext context, Product p) {
    final text = Theme.of(context).textTheme;
    final s = S(pregnancy.language);
    final affiliate = productIsAffiliate(p);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(product: p, controller: pregnancy))),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant),
          boxShadow: _tileShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            Image.network(
              productImageUrl(p),
              width: 150,
              height: 118,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 150,
                height: 118,
                alignment: Alignment.center,
                color: AppTheme.surfaceContainerHigh,
                child: Text(p.emoji, style: const TextStyle(fontSize: 44)),
              ),
            ),
            if (affiliate)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.open_in_new_rounded,
                        size: 10, color: Color(0xFFB36B00)),
                    const SizedBox(width: 3),
                    Text(s.prAffiliate,
                        style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB36B00))),
                  ]),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(p.price,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary600)),
                ]),
          ),
        ]),
      ),
    );
  }

  // ignore: unused_element
  Widget _productRow(BuildContext context, Product p, {bool divider = true}) {
    final text = Theme.of(context).textTheme;
    return Column(children: [
      InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(product: p, controller: pregnancy))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                productImageUrl(p),
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  color: AppTheme.surfaceContainerHigh,
                  child: Text(p.emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700, height: 1.25)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Text(p.price,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary600)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(p.summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelSmall
                                ?.copyWith(color: AppTheme.neutral500)),
                      ),
                    ]),
                  ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppTheme.neutral400),
          ]),
        ),
      ),
      if (divider) const Divider(height: 1, color: AppTheme.outlineVariant),
    ]);
  }

  // ignore: unused_element
  Widget _productCard(BuildContext context, Product p) {
    final s = S(pregnancy.language);
    final badge = _badgeMeta(p.badge);
    return GestureDetector(
      // Open this product's own page directly (so it can be viewed / bought),
      // not the generic recommended list.
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(product: p, controller: pregnancy))),
      child: SizedBox(
        width: 158,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: _tileShadow,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // The image fills the card so there's no wasted space below.
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Stack(children: [
                  Center(
                      child:
                          Text(p.emoji, style: const TextStyle(fontSize: 48))),
                  if (badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: badge.color,
                            borderRadius: BorderRadius.circular(99)),
                        child: Text(badge.label,
                            style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: AppTheme.primary900)),
                const SizedBox(height: 6),
                Row(children: [
                  Text(p.price,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppTheme.primary500.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(99)),
                    child: Text(s.prodSeeNow,
                        style: GoogleFonts.manrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary600)),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  ({String label, Color color})? _badgeMeta(ProductBadge b) {
    switch (b) {
      case ProductBadge.bestOverall:
        return (label: 'BEST', color: AppTheme.primary500);
      case ProductBadge.bestBudget:
        return (label: 'BUDGET', color: const Color(0xFF4F7A52));
      case ProductBadge.bestPremium:
        return (label: 'PREMIUM', color: AppTheme.tertiary500);
      case ProductBadge.sensitiveSkin:
        return (label: 'GENTLE', color: const Color(0xFF4A7BC8));
      case ProductBadge.newborns:
        return (label: 'NEWBORN', color: AppTheme.secondary500);
      case ProductBadge.none:
        return null;
    }
  }

  // Parked per the daily redesign - kept intact for an easy revert.
  // ignore: unused_element
  Widget _ritualsSection(
      BuildContext context, S s, AppLanguage lang, HomeDay day) {
    final rituals = <_Ritual>[
      _Ritual(DailyModule.grow, Icons.eco_rounded, s.ritualGrow, _sageBg, _sageFg),
      _Ritual(DailyModule.read, Icons.menu_book_rounded, s.ritualRead,
          AppTheme.surfaceContainerHigh, AppTheme.primary600),
      _Ritual(DailyModule.talk, Icons.forum_rounded, s.ritualTalk,
          AppTheme.secondary100, AppTheme.secondary700),
      _Ritual(DailyModule.garbhSanskar, Icons.self_improvement_rounded,
          s.ritualSanskar, _sandBg, AppTheme.tertiary500),
      _Ritual(DailyModule.nurture, Icons.favorite_rounded, s.ritualForYou,
          AppTheme.surfaceContainerHigh, AppTheme.primary600),
    ];
    final done = rituals.where((r) => home.isEngaged(r.module)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                s.todaysMoment,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Text(
              s.momentDone(done, rituals.length),
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final r in rituals)
                _ritualTile(context, r, day, lang),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ritualTile(
      BuildContext context, _Ritual r, HomeDay day, AppLanguage lang) {
    final done = home.isEngaged(r.module);
    return GestureDetector(
      onTap: () => _openRitual(context, r.module, day, lang),
      child: Container(
        width: 84,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _tileShadow,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: done ? 0.5 : 1,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: r.bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(r.icon, size: 21, color: r.fg),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: done ? AppTheme.neutral300 : AppTheme.primary900,
                    ),
                  ),
                ],
              ),
            ),
            if (done)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Opens the existing daily-moment module for [m] in a draggable sheet, and
  /// marks it engaged so the tile shows its "done" check.
  void _openRitual(
      BuildContext context, DailyModule m, HomeDay day, AppLanguage lang) {
    home.markEngaged(m);
    final Widget module = switch (m) {
      DailyModule.grow => GrowModule(day: day, lang: lang, home: home),
      DailyModule.read => ReadModule(day: day, lang: lang, home: home),
      DailyModule.talk => TalkModule(day: day, lang: lang, home: home),
      DailyModule.garbhSanskar =>
        GarbhSanskarModule(day: day, lang: lang, home: home),
      DailyModule.nurture => NurtureModule(day: day, lang: lang, home: home),
      DailyModule.movement => const SizedBox.shrink(),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              module,
            ],
          ),
        ),
      ),
    );
  }

  // --- affirmation -----------------------------------------------------------
  // Parked per the daily redesign - kept intact for an easy revert.
  // ignore: unused_element
  Widget _affirmationCard(S s, AppLanguage lang, HomeDay day) {
    var text = day.garbhSanskar.affirmation.of(lang).trim();
    if (text.isEmpty) text = day.nurture.content.of(lang).trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.secondary100, AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.secondary500.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_rounded,
                  size: 18, color: AppTheme.secondary500),
              const SizedBox(width: 10),
              Text(
                s.todaysAffirmation,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondary700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '“$text”',
            style: GoogleFonts.fraunces(
              fontSize: 19,
              fontStyle: FontStyle.italic,
              color: AppTheme.primary800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // (Quick row removed - Kicks lives in the Tools hub; Water was never a
  //  ParentVeda feature. Read Next now sits here instead.)

  // Garbh Sanskar entry card (opens the full Garbh library).
  // Daily "My Journal" - 5 quick entry types; everything is stored in the full
  // My Journal (reached via the "View My Journal Timeline" link / Profile).
  Widget _journalDailySection(BuildContext context, AppLanguage lang) {
    final s = S(lang);
    Widget tile(IconData icon, Color color, String label, VoidCallback onTap) =>
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 7),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: AppTheme.primary900)),
            ]),
          ),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _tileShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(s.jcMyJournal,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
          ),
          Text(s.formatShortDate(DateTime.now()),
              style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral500)),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          tile(Icons.edit_note_rounded, const Color(0xFFE0921C), s.jrWriteMemory,
              () => openJournalText(
                  context, pregnancy, JournalEntryType.memory)),
          const SizedBox(width: 8),
          tile(Icons.favorite_rounded, const Color(0xFF4F7A52), s.jrNoteForBaby,
              () => openJournalText(
                  context, pregnancy, JournalEntryType.noteForBaby)),
          const SizedBox(width: 8),
          tile(Icons.add_a_photo_rounded, const Color(0xFFFF5A79), s.jrAddPhoto,
              () => openJournalAddPhoto(context, pregnancy)),
          const SizedBox(width: 8),
          tile(Icons.mic_rounded, const Color(0xFF4A7BC8), s.jrRecordVoice,
              () => openJournalRecordVoice(context, pregnancy)),
          // Custom-tag option removed per the journal cleanup.
        ]),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => JournalScreen(controller: pregnancy))),
            child: Text(s.jcViewTimeline,
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary500)),
          ),
        ),
      ]),
    );
  }

  // Daily medication & supplements - shown INLINE on Home (today's items with a
  // tick-off), so it's usable with least clicks rather than hidden behind a CTA.
  // Scans & appointments due AROUND NOW (anchor week ± 2) + any upcoming
  // appointments, each scan with an "Already done" tick. Future scans surface
  // when their week arrives; past/not-done ones live behind "view all scans".
  // ignore: unused_element
  Widget _scansDailySection(BuildContext context, AppLanguage lang) {
    final s = S(lang);
    const teal = Color(0xFF2E9C8E);
    void openAll() => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TestsScansReportsScreen(controller: pregnancy)));
    return AnimatedBuilder(
      animation: Listenable.merge([ScansStore.instance, pregnancy]),
      builder: (context, _) {
        final cw = pregnancy.currentWeek;
        final due = scansDueAt(cw)
            .where((m) => !ScansStore.instance.isCompleted(m.id))
            .toList();
        final today = DateTime.now();
        final appts = ScansStore.instance.appointments
            .where((a) => !a.date
                .isBefore(DateTime(today.year, today.month, today.day)))
            .toList();
        return HomeCard(
          eyebrow: s.scnDailyTitle,
          icon: Icons.event_available_rounded,
          accent: teal,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (due.isEmpty && appts.isEmpty)
              Text(s.scnUpToDate,
                  style: GoogleFonts.manrope(
                      fontSize: 14.5,
                      height: 1.5,
                      color: const Color(0xFF5B5070)))
            else ...[
              for (final m in due) _scanDueRow(lang, s, m, teal),
              for (final a in appts) _apptDueRow(s, a, teal),
            ],
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: openAll,
                child: Text(s.scnViewAll,
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: teal)),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _scanDueRow(AppLanguage lang, S s, JourneyMilestone m, Color teal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Text(m.emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.title.of(lang),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary900)),
            Text(m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek),
                style: GoogleFonts.manrope(
                    fontSize: 12, color: AppTheme.neutral500)),
          ]),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => ScansStore.instance.markCompleted(
              scanId: m.id,
              journalTitle: m.title.of(lang),
              week: m.anchorWeek),
          style: OutlinedButton.styleFrom(
            foregroundColor: teal,
            side: BorderSide(color: teal.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            visualDensity: VisualDensity.compact,
          ),
          child: Text(s.scnAlreadyDone,
              style: GoogleFonts.manrope(
                  fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  // ignore: unused_element
  Widget _apptDueRow(S s, Appointment a, Color teal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.event_rounded,
              size: 18, color: Color(0xFF2E9C8E)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary900)),
            Text(
                s.formatShortDate(a.date) +
                    (a.time.isNotEmpty ? ' · ${a.time}' : ''),
                style: GoogleFonts.manrope(
                    fontSize: 12, color: AppTheme.neutral500)),
          ]),
        ),
      ]),
    );
  }

  Widget _medicationSection(BuildContext context, AppLanguage lang) {
    final s = S(lang);
    const green = Color(0xFF4F7A52);
    void openTracker() => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MedicineTrackerScreen(controller: pregnancy)));
    return AnimatedBuilder(
      animation:
          Listenable.merge([MedicineStore.instance, ReminderStore.instance]),
      builder: (context, _) {
        final store = MedicineStore.instance;
        final meds = store.activeMeds;
        return HomeCard(
          eyebrow: s.medDailyTitle,
          icon: Icons.medication_rounded,
          accent: green,
          // Top-right: add a reminder for herself (NOT tied to any medicine).
          trailing: IconButton(
            tooltip: s.mrAdd,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.notification_add_rounded, color: green),
            onPressed: () => showMedReminderEditor(context, pregnancy),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (meds.isEmpty)
              Text(s.medHomeSubtitle,
                  style: GoogleFonts.manrope(
                      fontSize: 14.5,
                      height: 1.5,
                      color: const Color(0xFF5B5070)))
            else
              for (final m in meds) _medRow(store, m, green),
            if (meds.isEmpty) const SizedBox(height: 16),
            if (meds.isEmpty)
              HomePrimaryButton(
                label: s.medTrackCta,
                trailingArrow: true,
                color: green,
                onTap: openTracker,
              )
            else
              Center(
                child: TextButton(
                  onPressed: openTracker,
                  child: Text(s.medManageCta,
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: green)),
                ),
              ),
            _medRemindersList(context, lang, green),
          ]),
        );
      },
    );
  }

  // Her self-set medication reminders (frequency + times + note), shown right on
  // the card. Tap to edit, ✕ to delete. Empty → nothing (the 🔔 invites adding).
  Widget _medRemindersList(BuildContext context, AppLanguage lang, Color green) {
    final s = S(lang);
    final rems = ReminderStore.instance.medication;
    if (rems.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      const Divider(height: 1, color: AppTheme.outlineVariant),
      const SizedBox(height: 8),
      Row(children: [
        Icon(Icons.notifications_active_rounded, size: 15, color: green),
        const SizedBox(width: 6),
        Text(s.mrTitle,
            style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: green)),
      ]),
      const SizedBox(height: 4),
      for (final r in rems)
        InkWell(
          onTap: () => showMedReminderEditor(context, pregnancy, existing: r),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.alarm_rounded, size: 16, color: green),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary900)),
                      Text(reminderSummary(s, r, context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                              fontSize: 11.5, color: AppTheme.neutral500)),
                    ]),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: AppTheme.neutral400),
                onPressed: () => ReminderStore.instance.remove(r.id),
              ),
            ]),
          ),
        ),
    ]);
  }

  Widget _medRow(MedicineStore store, Medication m, Color green) {
    final taken = store.isTakenToday(m.id);
    final sub = [m.dose, m.time].where((x) => x.isNotEmpty).join(' · ');
    return GestureDetector(
      onTap: () => store.toggleToday(m.id),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: taken ? green : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                  color: taken ? green : AppTheme.neutral400, width: 2),
            ),
            child: taken
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: taken ? AppTheme.neutral500 : AppTheme.primary900,
                      decoration:
                          taken ? TextDecoration.lineThrough : null)),
              if (sub.isNotEmpty)
                Text(sub,
                    style: GoogleFonts.manrope(
                        fontSize: 11.5, color: AppTheme.neutral500)),
            ]),
          ),
        ]),
      ),
    );
  }

  // Daily Garbh Sanskar - the 5 rituals, each showing TODAY's single item
  // (day-rotating, no in-pillar recommendations). The full 5-pillar Garbh lives
  // in Tools; tapping a ritual here opens its pillar screen in `daily: true`
  // mode. Progress N/5 + streak come from GarbhStore.
  Widget _garbhDailySection(BuildContext context, AppLanguage lang) {
    final s = S(lang);
    final cd = pregnancy.currentDay;
    return AnimatedBuilder(
      animation: GarbhStore.instance,
      builder: (context, _) {
        final store = GarbhStore.instance;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primary900.withValues(alpha: 0.05),
                  blurRadius: 22,
                  offset: const Offset(0, 10)),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppTheme.tertiary500.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.self_improvement_rounded,
                    color: AppTheme.tertiary500, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.garbhSanskar,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary900)),
                      Text(s.gsTodaysRituals,
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: AppTheme.neutral600)),
                    ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${store.doneCount}/${GarbhStore.dailyGoal}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.tertiary500)),
                if (store.streak > 0)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🔥', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Text(s.gsDayStreak(store.streak),
                        style: GoogleFonts.manrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFC97B4A))),
                  ]),
              ]),
            ]),
            const SizedBox(height: 12),
            // Short "what is Garbh Sanskar / why daily" intro before the rituals.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.tertiary500.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                s.gsHomeIntro,
                style: GoogleFonts.manrope(
                    fontSize: 12, height: 1.5, color: AppTheme.neutral700),
              ),
            ),
            const SizedBox(height: 14),
            _garbhPillarRow(context, s.gsShravan, s.gsShravanTag,
                shravanForDay(cd).title, '🎵', const Color(0xFFBE9C4E),
                store.isDone('shravan'),
                () => ShravanScreen(controller: pregnancy, daily: true)),
            // Standalone Vichara removed — its reflection now lives inside
            // "Samvad & Vichara" (row below). Kept commented for revert.
            // _garbhPillarRow(context, s.gsVichara, s.gsVicharaTag,
            //     s.gsVicharaTodo, '📖', const Color(0xFF6E8C74),
            //     store.isDone('vichara'),
            //     () => VicharaScreen(controller: pregnancy, daily: true)),
            _garbhPillarRow(context, s.gsSamvadVichara, s.gsSamvadTag,
                promptForDay(cd, garbhTrimester(pregnancy.currentWeek)).text,
                '🎙️', const Color(0xFFB98A7E),
                store.isDone('samvad'),
                () => SamvadScreen(controller: pregnancy, daily: true)),
            _garbhPillarRow(context, s.gsKriya, s.gsKriyaTag,
                kriyaForDay(cd).title, '🌿', const Color(0xFF5E8B7E),
                store.isDone('kriya'),
                () => KriyaScreen(controller: pregnancy, daily: true)),
            // Ahara (nourishment) commented out per request - kept for revert.
            // _garbhPillarRow(context, s.gsAhara, s.gsAharaTag,
            //     nutritionForDay(cd).tip, '🍲', const Color(0xFFC97B4A),
            //     store.isDone('ahara'),
            //     () => AharaScreen(controller: pregnancy, daily: true)),
          ]),
        );
      },
    );
  }

  Widget _garbhPillarRow(BuildContext context, String name, String tag,
      String todo, String emoji, Color accent, bool done, Widget Function() open) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => open())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: done ? 0.06 : 0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11)),
            child: Text(emoji, style: const TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(name,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accent)),
                ),
              ]),
              const SizedBox(height: 2),
              Text(todo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 12, color: AppTheme.neutral600)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF4F7A52) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                  color: done ? const Color(0xFF4F7A52) : AppTheme.neutral300,
                  width: 2),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
        ]),
      ),
    );
  }

  // ignore: unused_element
  Widget _garbhCard(BuildContext context, S s) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GarbhScreen(controller: pregnancy))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1E8DA), AppTheme.surface],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _tileShadow,
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppTheme.tertiary500.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.self_improvement_rounded,
                color: AppTheme.tertiary500, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.garbhSanskar,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900)),
                const SizedBox(height: 2),
                Text(s.homeGarbhSubtitle,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5, color: AppTheme.neutral600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ]),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _Ritual {
  const _Ritual(this.module, this.icon, this.label, this.bg, this.fg);
  final DailyModule module;
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
}
