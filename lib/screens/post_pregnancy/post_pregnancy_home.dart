// =============================================================================
//  PostPregnancyHome - My Child "Today" home (parenting app · daily briefing)
// -----------------------------------------------------------------------------
//  Rebuilt to the "Home (Today Journey)" spec: not a dashboard or a feature grid,
//  but a calm daily briefing that answers one question - "what does my child need
//  from me today?". A single, gently-revealed scroll: a Today's-Journey hero, then
//  What Matters Today, Continue Your Journey, Discover, Looking Ahead, a Child
//  Snapshot, Today's Focus, Tiny Wins and Quick Actions - every card earning its
//  place. Content is our Aarav / Leap-4 scenario, structured so a real context
//  engine can generate it per child later. A slim Deals shelf sits at the very
//  bottom (off the face). Nothing imports pregnancy code. Scenario: Priya & Aarav.
// =============================================================================

import 'package:flutter/material.dart';

import 'article_reader_screen.dart';
import 'development_area_screen.dart';
import 'explore_drawer.dart';
import 'recipes_screen.dart';
import 'food_recipe_screen.dart';
import 'growth_activity_screen.dart';
import 'leap_definition_screen.dart';
import 'pp_development_data.dart';
import 'pp_leaps_data.dart';
import 'pp_food_data.dart';
// The Health quick action now opens the full Health ecosystem; the old
// HealthGuideScreen import is kept (commented) for easy revert.
// import 'health_guide_screen.dart';
import 'health_home_screen.dart';
import 'journal_v2/journal_capture_screens.dart';
import 'journal_v2/journal_home_screen.dart';
import 'my_child_screen.dart';
import 'pp_common.dart';
import 'pp_products_data.dart';
import 'product_detail_screen.dart';
import 'products_compare_screen.dart';
import 'snapshot_expanded_screen.dart';
import 'solve_problem_screen.dart';
import 'vax_detail_screen.dart';
import 'vax_tracker_screen.dart';
// Redesigned tracker (vax_tracker_screen) is the live entry now; the old
// VaccinationScreen is kept for revert.
// import 'vaccination_screen.dart';
// "Looking ahead → Leap 5" now opens the full leap page; the standalone
// WonderWeekScreen is kept for revert but no longer wired here.
// import 'wonder_week_screen.dart';

// section-icon tints
const Color _tPurple = Color(0xFFEDEAF7);
const Color _tBlue = Color(0xFFEAF1FB);
const Color _tGreen = Color(0xFFEAF4EE);
const Color _blueFg = Color(0xFF3B6EA5);
const Color _greenFg = Color(0xFF1F8A5B);

class PostPregnancyHome extends StatefulWidget {
  const PostPregnancyHome({super.key});

  @override
  State<PostPregnancyHome> createState() => _PostPregnancyHomeState();
}

class _PostPregnancyHomeState extends State<PostPregnancyHome> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Editing coming soon'), behavior: SnackBarBehavior.floating),
      );

  // Progressive reveal: each section fades + rises with a staggered delay.
  Widget _rv(int i, Widget c) {
    final start = (i * 0.07).clamp(0.0, 0.6);
    final a = CurvedAnimation(parent: _reveal, curve: Interval(start, (start + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: a,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, (1 - a.value) * 18), child: child),
      ),
      child: c,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ppBg,
      drawer: const ExploreDrawer(),
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 58, bottom: 116),
          children: [
            _pad(_greeting()),
            const SizedBox(height: 18),
            _rv(0, _hero()),
            const SizedBox(height: 28),
            _rv(1, _whatMatters()),
            const SizedBox(height: 28),
            _rv(2, _continueJourney()),
            const SizedBox(height: 28),
            _rv(3, _discover()),
            const SizedBox(height: 28),
            _rv(4, _lookingAhead()),
            const SizedBox(height: 28),
            _rv(5, _childSnapshot()),
            const SizedBox(height: 28),
            _rv(6, _todaysFocus()),
            const SizedBox(height: 28),
            _rv(7, _tinyWins()),
            const SizedBox(height: 28),
            _rv(8, _quickActions()),
            const SizedBox(height: 32),
            _rv(9, _dealsSection()),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 48,
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)])),
            ),
          ),
        ),
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 0)),
      ]),
    );
  }

  // ---- greeting ----------------------------------------------------------
  Widget _greeting() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ppEyebrow('Tuesday, 8 July', color: ppSoft, spacing: 0.8),
            const SizedBox(height: 4),
            Text('Good morning, Priya', style: ppJakarta(22)),
          ]),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          behavior: HitTestBehavior.opaque,
          child: const Icon(Icons.menu_rounded, size: 22, color: ppInk),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          key: const ValueKey('child-photo'),
          onTap: _openChildDetails,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
            clipBehavior: Clip.antiAlias,
            child: const PpStriped(height: 42),
          ),
        ),
      ]);

  // ---- 1 · hero (Today's Journey) ----------------------------------------
  Widget _hero() => _pad(GestureDetector(
        onTap: () => _push(const SnapshotExpandedScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFE6D8F1)]),
            borderRadius: BorderRadius.circular(26),
            boxShadow: ppCardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            Positioned(right: -36, top: -34, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.35)))),
            Positioned(right: 26, top: 26, child: Icon(Icons.wb_twilight_rounded, size: 28, color: ppPurple.withValues(alpha: 0.85))),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Flexible(child: ppEyebrow("Today · Aarav is 4 months", color: ppPurple, spacing: 1.2)),
                ]),
                const SizedBox(height: 16),
                Text(
                  "Today, Aarav is working out that the world moves in smooth, connected sequences. Babies his age start reaching with real intent and studying your hands with wonder - a little slow, narrated play and plenty of eye contact goes a long way.",
                  style: ppFraunces(19, h: 1.45),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Flexible(child: Text("Explore today's journey", style: ppBody(13, color: Colors.white, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 7),
                        const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
                      ]),
                    ),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ));

  // ---- 2 · what matters today --------------------------------------------
  Widget _whatMatters() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_sectionHeader('What matters today')),
        const SizedBox(height: 14),
        _pad(Column(children: [
          _bigRow(Icons.psychology_outlined, _tPurple, ppPurple, "Today's brain activity", 'Peekaboo - the first seed of object permanence', () => _push(const GrowthActivityScreen())),
          const SizedBox(height: 12),
          _bigRow(Icons.vaccines_outlined, ppCoralTint, ppCoral, 'PCV · dose 3 due 22 Jul', 'Free at a govt centre · tap to plan the visit', () => _push(const VaxTrackerScreen())),
          const SizedBox(height: 12),
          _bigRow(Icons.menu_book_outlined, _tBlue, _blueFg, "Today's read", 'Why baby sleep cycles change at 4 months', () => _push(const ArticleReaderScreen())),
        ])),
      ]);

  // ---- 3 · continue your journey -----------------------------------------
  Widget _continueJourney() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_sectionHeader('Continue your journey')),
        const SizedBox(height: 14),
        // Continue the unfinished task itself - an in-progress journal memory opens
        // the Journal editor directly (not the Storybook preview).
        _pad(_bigRow(Icons.edit_note_rounded, _tPurple, ppPurple, "Today's memory", 'You started a note this morning - finish it', () => _push(const WriteStoryScreen()))),
        const SizedBox(height: 12),
        _pad(_bigRow(Icons.article_outlined, _tGreen, _greenFg, 'The 4-month sleep regression', 'You were halfway through the guide', () => _push(const SolveProblemScreen()))),
      ]);

  // ---- 4 · discover -------------------------------------------------------
  Widget _discover() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_sectionHeader('Discover')),
        const SizedBox(height: 14),
        SizedBox(
          height: 208,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), children: [
            _discoverCard('Activity', 'Reach for the ring', '4 min · grasp & intent', () => _push(const GrowthActivityScreen(activity: kActReachRing))),
            const SizedBox(width: 14),
            _discoverCard('Recipe', 'Sweet potato mash', 'from 6 months · vitamin A', () => _push(FoodRecipeScreen(recipe: foodRecipeById('sweetpotatomash')))),
            const SizedBox(width: 14),
            _discoverCard('Product', 'Dozy white-noise soother', '₹1,499 · verified', () => _push(ProductDetailScreen(product: productById('dozy')))),
          ]),
        ),
      ]);

  Widget _discoverCard(String tag, String title, String meta, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 190,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              const PpStriped(height: 118, radius: 16, border: true),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999)),
                  child: Text(tag.toUpperCase(), style: ppBody(9, color: ppPurple, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Text(title, style: ppJakarta(14).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(meta, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  // ---- 5 · looking ahead --------------------------------------------------
  Widget _lookingAhead() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_sectionHeader('Looking ahead')),
        const SizedBox(height: 14),
        SizedBox(
          height: 128,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), children: [
            _aheadCard('Tomorrow', 'A new sound', Icons.graphic_eq_rounded, () => _push(const GrowthActivityScreen(activity: kActNewSound))),
            const SizedBox(width: 12),
            _aheadCard('in ~6 weeks', 'Leap 5 begins', Icons.brightness_4_rounded, () => _push(LeapDefinitionScreen(leap: leapByNumber(5)))),
            const SizedBox(width: 12),
            _aheadCard('in ~7 weeks', '6-month vaccines', Icons.vaccines_outlined, () => _push(const VaxDetailScreen(visitId: 'mo6'))),
            const SizedBox(width: 12),
            _aheadCard('at 6 months', 'First solids', Icons.restaurant_outlined, () => _push(const RecipesScreen())),
          ]),
        ),
      ]);

  Widget _aheadCard(String when, String title, IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: _tPurple, borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 17, color: ppPurple)),
            const Spacer(),
            Text(when.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
            const SizedBox(height: 3),
            Text(title, style: ppJakarta(14).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  // ---- child snapshot -----------------------------------------------------
  Widget _childSnapshot() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_sectionHeader('Child snapshot', action: 'My Child →', onAction: () => _push(const MyChildScreen()))),
        const SizedBox(height: 14),
        _pad(GestureDetector(
          onTap: () => _push(const MyChildScreen()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair), boxShadow: const [BoxShadow(color: Color(0x146A30B6), blurRadius: 22, spreadRadius: -16, offset: Offset(0, 10))]),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              _domainRow(Icons.psychology_outlined, ppPurple, 'Brain', 'Developing', onTap: () => _push(DevelopmentAreaScreen(area: devAreaById('cognitive')))),
              _domainRow(Icons.directions_walk_rounded, _greenFg, 'Motor', 'On track', onTap: () => _push(DevelopmentAreaScreen(area: devAreaById('gross_motor')))),
              _domainRow(Icons.chat_bubble_outline_rounded, ppCoral, 'Language', 'Emerging', onTap: () => _push(DevelopmentAreaScreen(area: devAreaById('language')))),
              _domainRow(Icons.favorite_border, ppPurple, 'Emotional', 'Blossoming', last: true, onTap: () => _push(DevelopmentAreaScreen(area: devAreaById('emotional')))),
            ]),
          ),
        )),
      ]);

  Widget _domainRow(IconData icon, Color fg, String label, String status, {bool last = false, VoidCallback? onTap}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            Icon(icon, size: 19, color: fg),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: fg.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
              child: Text(status, style: ppBody(11, color: fg, w: FontWeight.w700)),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 17, color: ppMuted),
            ],
          ]),
        ),
      );

  // ---- today's focus ------------------------------------------------------
  Widget _todaysFocus() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_sectionHeader("Today's focus")),
        const SizedBox(height: 14),
        _pad(GestureDetector(
          onTap: () => _push(const GrowthActivityScreen(activity: kActNarrate)),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF1F4), Color(0xFFF7E9EF)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: ppCoral),
                const SizedBox(width: 8),
                ppEyebrow('Language', color: ppCoral, spacing: 1.2),
              ]),
              const SizedBox(height: 12),
              Text('Your baby is learning language long before he speaks.', style: ppFraunces(20, h: 1.3)),
              const SizedBox(height: 8),
              Text('Try narrating your everyday moments today - "now we\'re pouring the water" - and pause, as if for his reply. Those small conversations build his ear for language.',
                  style: ppBody(14, h: 1.6)),
            ]),
          ),
        )),
      ]);

  // ---- tiny wins ----------------------------------------------------------
  Widget _tinyWins() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_sectionHeader('Tiny wins')),
        const SizedBox(height: 12),
        _pad(Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            _win("Logged today's memory", done: true, onTap: () => _push(const JournalV2Home())),
            _win("Read today's article", done: true, onTap: () => _push(const ArticleReaderScreen())),
            _win('Completed tummy time', done: false, onTap: () => _push(const GrowthActivityScreen(activity: kActTummyTime))),
            _win("Finished today's activity", done: false, onTap: () => _push(const GrowthActivityScreen()), last: true),
          ]),
        )),
      ]);

  Widget _win(String text, {required bool done, required VoidCallback onTap, bool last = false}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? ppPurple : Colors.transparent,
                shape: BoxShape.circle,
                border: done ? null : Border.all(color: const Color(0xFFC7BBD6), width: 1.5),
              ),
              child: done ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: ppBody(14, color: done ? ppMuted : ppInk, w: done ? FontWeight.w500 : FontWeight.w600))),
            if (!done) const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
          ]),
        ),
      );

  // ---- quick actions ------------------------------------------------------
  Widget _quickActions() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_sectionHeader('Quick actions')),
        const SizedBox(height: 14),
        _pad(Row(children: [
          _qa(Icons.auto_awesome_outlined, 'Ask Veda', () => openPpTab(context, 1)),
          _qa(Icons.menu_book_outlined, 'Journal', () => _push(const JournalV2Home())),
          _qa(Icons.compare_arrows_rounded, 'Compare', () => _push(const ProductsCompareScreen())),
          // Was: _push(const HealthGuideScreen()) - now opens the Health ecosystem:
          _qa(Icons.monitor_heart_outlined, 'Health', () => _push(const HealthHomeScreen())),
        ])),
      ]);

  Widget _qa(IconData icon, String label, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(17)), child: Icon(icon, size: 22, color: ppPurple)),
            const SizedBox(height: 8),
            Text(label, style: ppBody(11, color: ppInk, w: FontWeight.w600)),
          ]),
        ),
      );

  // ---- shared -------------------------------------------------------------
  Widget _sectionHeader(String title, {String? action, VoidCallback? onAction}) => Row(children: [
        Expanded(child: Text(title, style: ppJakarta(18))),
        if (action != null) GestureDetector(onTap: onAction, behavior: HitTestBehavior.opaque, child: Text(action, style: ppBody(12, color: ppPurple, w: FontWeight.w700))),
      ]);

  Widget _bigRow(IconData icon, Color bg, Color fg, String title, String sub, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair), boxShadow: const [BoxShadow(color: Color(0x116A30B6), blurRadius: 18, spreadRadius: -14, offset: Offset(0, 8))]),
          child: Row(children: [
            Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 20, color: fg)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(sub, style: ppBody(12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  // ---- deals for the day (kept at the very bottom) -----------------------
  Widget _dealsSection() {
    const deals = <(String, int)>[
      ('playgym', 20),
      ('clothbook', 15),
      ('snugglesack', 25),
      ('carrier', 15),
      ('thermometer', 20),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Deals for the day', style: ppJakarta(18)),
            const SizedBox(height: 2),
            Text("Handpicked for Aarav's stage - affiliate & ParentVeda picks.", style: ppBody(12)),
          ]),
        ),
        const SizedBox(width: 10),
        GestureDetector(onTap: () => openPpTab(context, 4), behavior: HitTestBehavior.opaque, child: ppSeeAll()),
      ])),
      const SizedBox(height: 14),
      SizedBox(
        height: 242,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: deals.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) => _dealCard(deals[i].$1, deals[i].$2),
        ),
      ),
      const SizedBox(height: 12),
      _pad(Text('Sponsored & affiliate picks - always labelled, and never on your research pages.',
          textAlign: TextAlign.center, style: ppBody(11, color: ppMuted, h: 1.5))),
    ]);
  }

  Widget _dealCard(String id, int disc) {
    final p = productById(id);
    final original = (p.price / (1 - disc / 100)).round();
    return GestureDetector(
      onTap: () => _push(ProductDetailScreen(product: p)),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 158,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              const PpStriped(height: 126, radius: 16, border: true),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(999)),
                  child: Text('$disc% OFF', style: ppBody(9, color: Colors.white, w: FontWeight.w700).copyWith(letterSpacing: 0.4)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 9),
          Text(p.name, style: ppJakarta(13, w: FontWeight.w600).copyWith(height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            Flexible(child: Text(p.priceLabel, style: ppBody(14, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 6),
            Flexible(child: Text(_money(original), style: ppBody(11, color: ppMuted).copyWith(decoration: TextDecoration.lineThrough), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 3),
          Text(p.retailer == 'In-app' ? 'ParentVeda · in-app' : 'via ${p.retailer}', style: ppBody(10, color: ppMuted)),
        ]),
      ),
    );
  }

  String _money(int n) {
    final s = n.toString();
    if (s.length <= 3) return '₹$s';
    return '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  // ---- child details bottom sheet (unchanged) ----------------------------
  void _openChildDetails() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Aarav's details", style: ppJakarta(18)),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(width: 30, height: 30, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, size: 16, color: ppSoft)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)), clipBehavior: Clip.antiAlias, child: const PpStriped(height: 70)),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: _soon,
                        child: Container(width: 24, height: 24, alignment: Alignment.center, decoration: BoxDecoration(color: ppPurple, shape: BoxShape.circle, border: Border.all(color: ppBg, width: 2)), child: const Icon(Icons.edit, size: 11, color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Aarav', style: ppJakarta(20)), const SizedBox(height: 2), Text('4 months 1 week', style: ppBody(13))])),
                GestureDetector(onTap: _soon, behavior: HitTestBehavior.opaque, child: Text('Edit', style: ppBody(13, color: ppPurple, w: FontWeight.w700))),
              ]),
              const SizedBox(height: 10),
              _detailRow('Date of birth', const [TextSpan(text: '8 March 2026')], top: true),
              _detailRow('Sex', const [TextSpan(text: 'Boy')], top: true),
              _detailRow('Weight', [const TextSpan(text: '6.4 kg'), TextSpan(text: ' · 50th', style: ppBody(14, color: ppMuted))], top: true),
              _detailRow('Height', [const TextSpan(text: '63 cm'), TextSpan(text: ' · 48th', style: ppBody(14, color: ppMuted))], top: true),
              _detailRow('Head', [const TextSpan(text: '41 cm'), TextSpan(text: ' · 52nd', style: ppBody(14, color: ppMuted))], top: true, bottom: true),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, List<InlineSpan> value, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: Border(top: top ? const BorderSide(color: ppHair) : BorderSide.none, bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none)),
        child: Row(children: [
          Expanded(child: Text(label, style: ppBody(13, color: ppSoft))),
          const SizedBox(width: 12),
          Text.rich(TextSpan(children: value), style: ppBody(14, color: ppInk, w: FontWeight.w600)),
        ]),
      );
}
