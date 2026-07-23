// =============================================================================
//  MyChildScreen - the parenting home ("Who is my child today?")
// -----------------------------------------------------------------------------
//  The landing screen of the parenting app (route 'pp/my_child', bottom-nav tab
//  0). Built around the child's current developmental LEAP: a leap header, the
//  child's identity + editable growth, a daily tip, the leap video + expandable
//  description, the Child Snapshot, Milestones, the Journal, leap-related Watch &
//  Learn rails, and a one-line "looking ahead" to the next leap.
//
//  `home: true` renders it as the home (hamburger + Explore drawer + bottom nav,
//  no back button). `home: false` renders it as a plain pushed page. Leap and
//  growth are derived live from ChildProfileStore. No green - warm palette.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'development_area_screen.dart';
import 'dev_stage_detail_screen.dart';
import 'explore_drawer.dart';
import 'family_profile_screen.dart';
// Nutrition now opens NutritionScreen (nutrition-led) rather than Recipes.
// Kept for revert.
// import 'recipes_screen.dart';
// Old light growth screen retired in favour of the new Growth Journey tool
// (kept for revert). import 'health_growth_screen.dart';
import 'growth_journey_screen.dart';
import 'health_timeline_screen.dart';
import 'journal_v2/journal_capture_screens.dart';
import 'journal_v2/journal_home_screen.dart';
import 'journal_v2/journal_storybook_screens.dart';
import 'leap_calendar_screen.dart';
import 'leap_definition_screen.dart';
import 'pp_child_profile.dart';
import 'multichild_sheet.dart';
import 'pp_common.dart';
import 'pp_daily_tips.dart';
import 'pp_development_data.dart';
import 'pp_leaps_data.dart';
import 'phase_detail_screen.dart';
import 'phase_map_screen.dart';
import '../../brand/brand_models.dart';
import '../../brand/brand_notifications.dart';
import 'pp_phases_data.dart';
import 'pp_reading_data.dart';
import 'pp_watch_data.dart';
import 'reading_collection_screen.dart';
import 'pp_phase_faqs.dart';
import 'recommendations_screen.dart';
import 'reco_detail_screen.dart';
import 'pp_reco_data.dart';
import 'askveda_screen.dart';
import 'nutrition_screen.dart';
import 'reco_search_screen.dart';
import 'reading_reader_screen.dart';
import 'watch_category_screen.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class MyChildScreen extends StatefulWidget {
  const MyChildScreen({super.key, this.home = false});

  /// When true, render as the app home (hamburger + drawer + bottom nav).
  final bool home;

  @override
  State<MyChildScreen> createState() => _MyChildScreenState();
}

class _MyChildScreenState extends State<MyChildScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _leapExpanded = false;

  @override
  void initState() {
    super.initState();
    // Opening the parenting home is a natural moment to consider a sponsored
    // notification. maybeSend does all the deciding — targeting, the frequency
    // gap, the cap — and sends nothing far more often than it sends. Only from
    // the real home (home: true), never a pushed sub-view, and never in a test
    // (the widget tests pump this screen constantly).
    if (widget.home) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BrandNotifications.instance.maybeSend(stage: BrandStage.parenting);
      });
    }
  }
  /// Which FAQ is open (-1 = none). One at a time keeps the card short.
  int _faqOpen = -1;

  ChildProfileStore get _child => ChildProfileStore.instance;

  // 18px side padding, matching the pregnancy home (fromLTRB(18,…,18,…)). The
  // parenting home used 24, which made its cards visibly narrower side by side.
  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: c);

  // Hero gradient end + warm bloom, both lifted from the pregnancy hero so the
  // two cards read as one product: AppTheme.primary700 and secondary300.
  static const Color _heroDeep = Color(0xFF502489);
  static const Color _heroWarm = Color(0xFFFF9CAF);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // The parenting home read as blatantly white; the pregnancy home sits on
      // a slight purple tint (#F3EEF7) so its white cards stand out. Matching it.
      backgroundColor: widget.home ? ppPanel : ppBg,
      drawer: widget.home ? const ExploreDrawer() : null,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          AnimatedBuilder(
            animation: _child,
            builder: (context, _) {
              // The whole home runs on age phases now. Nothing below reads a
              // leap any more; the retired widgets keep their own.
              final phase = currentPhase(_child);
              return ListView(
                padding: EdgeInsets.only(top: 12, bottom: widget.home ? 100 : 40),
                children: [
                  // The old top row was a lone hamburger + a "My Child" label —
                  // a whole row spent on nothing. It is now a proper brand
                  // header: ParentVeda mark + wordmark + search / profile /
                  // Explore icons, exactly like the pregnancy home.
                  _pad(_brandHeader()),
                  const SizedBox(height: 16),
                  // "HOW <NAME> IS TODAY" labels the hero from OUTSIDE the card,
                  // exactly as "WEEKLY SNAPSHOT" does on the pregnancy home
                  // (home_screen_b.dart) — same eyebrow, same 8px gap, same
                  // uppercase purple. It was briefly folded inside the card as a
                  // greeting line; out here it reads as a section label, and the
                  // uppercasing also solves the unnamed case, where the name
                  // falls back to "Your baby" and produced "How Your baby is
                  // today" with a stray capital mid-sentence.
                  _pad(_heroEyebrow()),
                  const SizedBox(height: 8),
                  _leapHero(phase),
                  const SizedBox(height: 22),
                  // Today's Parenting Tip now sits ABOVE the video: a narrow,
                  // centred card (70% width, two lines, "Read more") so it
                  // reads as a quick thought rather than a section.
                  _dailyTip(),
                  const SizedBox(height: 22),
                  // Video follows the tip. It carries its own header inside the
                  // card (like the pregnancy "Today's Video"), so it needs no
                  // page-level lead above it.
                  // Always renders now: the video comes from the phase's Watch
                  // category rather than a hardcoded id, so there is no "this
                  // phase has no video" case left to guard against.
                  _leapVideo(phase),
                  const SizedBox(height: 26),
                  _leapDescription(phase),
                  // Section beat tightened 34 -> 26. The pregnancy home runs a
                  // 16 beat with 20/24 at major breaks; 34 was a big part of
                  // why the parenting pages felt like a different product.
                  const SizedBox(height: 26),
                  _snapshot(),
                  const SizedBox(height: 26),
                  _milestones(),
                  const SizedBox(height: 26),
                  _journal(),
                  const SizedBox(height: 26),
                  _leapWatch(phase),
                  const SizedBox(height: 26),
                  _leapLearn(phase),
                  const SizedBox(height: 26),
                  // Products land AFTER the watch/read rails, mixing picks from
                  // across the leap's milestones and domains rather than one
                  // narrow category.
                  _leapProducts(phase),
                  const SizedBox(height: 26),
                  // Top 3 questions for this age, rotating each app open, with
                  // a way through to Ask Veda for anything else. Sits before
                  // "what's coming next" so the current phase finishes first.
                  _faqs(phase),
                  const SizedBox(height: 26),
                  _lookingAhead(),
                  // REMOVED per 17-18 July review: the Memory + Health
                  // timelines that briefly sat at the bottom of this page. The
                  // home is about now, not a scroll through history; both live
                  // on in Journal and Health. Kept commented for revert.
                  // const SizedBox(height: 26),
                  // _timelines(),
                ],
              );
            },
          ),
          if (widget.home) const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 0)),
        ]),
      ),
    );
  }

  // ---- brand header (home) / back (pushed) --------------------------------
  //  Mirrors the pregnancy home exactly: mark + wordmark on the left, then the
  //  same round action icons on the right — search, profile, and the Explore
  //  drawer. The full-width search bar was dropped in favour of the search
  //  icon, matching the pregnancy home the user pointed at.
  Widget _brandHeader() {
    if (!widget.home) return ppBack(context, 'My Child');
    return Row(children: [
      Image.asset('assets/brand/pv-mark.png', height: 28),
      const SizedBox(width: 8),
      // Plain Text (not Flexible): the pregnancy header does the same, so the
      // wordmark always shows in full rather than sharing free space with the
      // Spacer and truncating. The smaller icons opposite leave room for it.
      Text('ParentVeda',
          style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w800, color: ppPurple, letterSpacing: -0.5)),
      const Spacer(),
      _headerIcon(Icons.search_rounded, () => _push(const RecoSearchScreen())),
      const SizedBox(width: 8),
      _headerIcon(Icons.person_outline_rounded, () => _push(const FamilyProfileScreen())),
      const SizedBox(width: 8),
      _headerIcon(Icons.menu_rounded, () => _scaffoldKey.currentState?.openDrawer()),
    ]);
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: ppCardShadow),
          child: Icon(icon, size: 20, color: ppPurple),
        ),
      );

  // =========================================================================
  //  Leap hero — the child, the leap, and where they are in it, in one card
  // -------------------------------------------------------------------------
  //  Replaces the old _leapHeader + _identity pair (both kept below, commented
  //  out, for revert). Everything they showed survives: photo, name, leap label
  //  and name, the character, the storm→sun progress, and the route into the
  //  leap page. What is gone is the repetition — the two blocks announced the
  //  child twice, back to back ("AARAV IS IN / Leap 4", then "Curious Explorer
  //  / Aarav") — and roughly 90pt of air that pushed the video off screen one.
  //
  //  The photo and the name open the child switcher, which is the affordance
  //  MultiChildSheet's own header always described ("tap Aarav ▾") and which
  //  had gone missing from the app entirely.
  // =========================================================================
  // ===========================================================================
  //  Hero — rebuilt 21 Jul against the pregnancy hero (_heroCard, home_screen_b)
  // ---------------------------------------------------------------------------
  //  Fixes the three faults called out on the old one (kept below as
  //  _leapHeroLegacy):
  //
  //  1. THE PHASE NAME NOW HAS ONE HOME. It used to trail the age line ("3
  //     months · Hands discovered") and repeat on the journey row. Here the
  //     identity line carries the AGE ONLY, and the phase owns the block below
  //     it — number, name, tagline — so it is stated once, properly.
  //
  //  2. THE JOURNEY BAR SAYS WHAT IT IS. A lone dot on a Birth→5 years track
  //     answered "how far" but never "through what". It now names the phase, its
  //     position ("Phase 4 of 20"), and what the phase means (phase.tagline) —
  //     and the track carries a tick per phase, so the road has stops on it
  //     rather than being a bare line.
  //
  //  3. IT IS LIGHTER. The gradient no longer darkens the accent toward black
  //     (which muddied the purple); it runs ppPurple → _heroDeep, the same
  //     primary500 → primary700 move the pregnancy hero makes. A warm pink
  //     bloom is borrowed from that hero too — it is what stops a purple block
  //     reading as flat. Growth is separated by a HAIRLINE instead of a black
  //     inset panel, which is what made the card feel bottom-heavy.
  // ===========================================================================
  Widget _leapHero(AgePhase phase) {
    final e = _child.expected;
    const w70 = Color(0xB3FFFFFF);
    return _pad(Container(
      decoration: BoxDecoration(
        // Purple → deeper purple. No black: mixing toward black greys a
        // saturated purple out, which is exactly how the old card went muddy.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ppPurple, _heroDeep],
        ),
        borderRadius: BorderRadius.circular(ppCardRadius),
        boxShadow: ppCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned(
          right: -36,
          top: -36,
          child: _bloom(150, Colors.white.withValues(alpha: 0.10)),
        ),
        // The warm one. Straight from the pregnancy hero (secondary300 @ 25%),
        // and the single biggest reason that card looks alive and this one did
        // not — a purple block lit only by white blooms stays flat.
        Positioned(
          right: 26,
          bottom: -42,
          child: _bloom(104, _heroWarm.withValues(alpha: 0.24)),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ---- identity: photo, name, AGE ONLY ---------------------------
            Row(children: [
              GestureDetector(
                onTap: () => showMultiChildSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const PpStriped(height: 56),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () => showMultiChildSheet(context),
                    behavior: HitTestBehavior.opaque,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                        child: Text(_child.name,
                            style: ppFraunces(25, color: Colors.white, h: 1.05),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: w70),
                    ]),
                  ),
                  const SizedBox(height: 3),
                  // Age only. The phase moved to its own block below.
                  Text(phase.ageLabel,
                      style: ppBody(12.5, color: Colors.white.withValues(alpha: 0.9), w: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),

            const SizedBox(height: 18),
            _phaseJourney(phase),

            // ---- growth, separated by a hairline (was a black inset panel) --
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
            const SizedBox(height: 14),
            Row(children: [
              Text('GROWTH', style: ppBody(10.5, color: w70, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
              const Spacer(),
              _heroAction(Icons.edit_outlined, 'Edit', _openGrowthEdit),
              const SizedBox(width: 14),
              _heroAction(Icons.show_chart_rounded, 'Chart', () => _push(const GrowthJourneyScreen())),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _heroStat('Weight', _m(_child.weightKg, 1), 'kg', '~${e.weightKg.toStringAsFixed(1)}')),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.18)),
              Expanded(child: _heroStat('Height', _m(_child.heightCm, 0), 'cm', '~${e.heightCm.toStringAsFixed(0)}')),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.18)),
              Expanded(child: _heroStat('Head', _m(_child.headCm, 0), 'cm', '~${e.headCm.toStringAsFixed(0)}')),
            ]),
          ]),
        ),
      ]),
    ));
  }

  Widget _bloom(double d, Color c) =>
      Container(width: d, height: d, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  // ===========================================================================
  //  Phase journey — the phase, where it sits, and what it means
  // ---------------------------------------------------------------------------
  //  The old bar (kept as _phaseJourneyLegacy) drew a dot on an unmarked track.
  //  This one answers the three questions a parent actually has: which phase is
  //  he in, how far through the whole road is that, and what does this phase
  //  mean. The tagline is the part that was missing entirely — every AgePhase
  //  has carried one all along ("The world gets interesting") and nothing on
  //  this screen ever showed it.
  // ===========================================================================
  Widget _phaseJourney(AgePhase phase) {
    const w70 = Color(0xB3FFFFFF);
    final progress = journeyProgress(_child);
    final next = nextPhase(_child);
    final idx = kPhases.indexWhere((p) => p.number == phase.number);

    return GestureDetector(
      onTap: () => _push(const PhaseMapScreen()),
      behavior: HitTestBehavior.opaque,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('PHASE ${idx + 1} OF ${kPhases.length}',
              style: ppBody(10.5, color: w70, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
          const Spacer(),
          Text('Phase map', style: ppBody(10.5, color: w70, w: FontWeight.w700)),
          const Icon(Icons.chevron_right_rounded, size: 15, color: w70),
        ]),
        const SizedBox(height: 6),
        // The phase, stated once, at a size that says it matters.
        Text(phase.name,
            style: ppJakarta(16, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(phase.tagline,
            style: ppBody(12, color: Colors.white.withValues(alpha: 0.82), h: 1.35),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 13),
        // The track, now with a tick per phase — the road has stops on it.
        LayoutBuilder(builder: (context, c) {
          final x = (c.maxWidth - 14) * progress;
          return SizedBox(
            height: 14,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: 0, right: 0, top: 6,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999)),
                ),
              ),
              // One faint tick per phase, so the bar reads as twenty stages
              // rather than an unmarked five-year smear.
              for (var i = 0; i < kPhases.length; i++)
                Positioned(
                  left: 7 + (c.maxWidth - 14) * (i / (kPhases.length - 1)) - 0.5,
                  top: 4,
                  child: Container(width: 1, height: 7, color: Colors.white.withValues(alpha: 0.30)),
                ),
              Positioned(
                left: 0, top: 6,
                child: Container(
                  width: x + 7,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(999)),
                ),
              ),
              Positioned(
                left: x,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: ppPurple, width: 3)),
                ),
              ),
            ]),
          );
        }),
        const SizedBox(height: 7),
        Row(children: [
          Text('Birth', style: ppBody(10.5, color: w70, w: FontWeight.w700)),
          const Spacer(),
          Text('5 years', style: ppBody(10.5, color: w70, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
                next != null
                    ? 'Next: ${next.name.toLowerCase()}, around ${next.ageLabel}.'
                    : 'The last stretch before school.',
                style: ppBody(11.5, color: Colors.white.withValues(alpha: 0.9)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      ]),
    );
  }

  // SUPERSEDED 21 Jul by the _leapHero below. Kept, unmounted, for revert.
  // Three things were wrong with it, all visible on screen:
  //   1. the phase name had no home — it sat as a suffix on the age line AND
  //      again on the journey row, so it read as scattered rather than stated;
  //   2. the journey bar showed a dot on a Birth→5 years track with no sense of
  //      which phase, of how many, or what the phase actually means;
  //   3. it looked heavy: the gradient darkened the accent toward BLACK, and
  //      the growth block was a black 16% panel inset into it. The pregnancy
  //      hero goes purple→purple (primary500→primary700), adds a warm pink
  //      bloom for lift, and separates its sections with a hairline instead of
  //      a dark box. Same brand, two different moods.
  // ignore: unused_element
  Widget _leapHeroLegacy(AgePhase phase) {
    final a = phase.accent;
    final e = _child.expected;
    const w70 = Color(0xB3FFFFFF); // white @70%, for hairlines / secondary text
    return _pad(Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a, Color.lerp(a, Colors.black, 0.32)!]),
        borderRadius: BorderRadius.circular(ppCardRadius),
        // The pregnancy app's ink lift, not the purple glow the parenting side
        // grew on its own. See ppCardShadow in pp_common.dart.
        boxShadow: ppCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        // Soft light-blooms, the way the pregnancy hero has texture behind its
        // gradient rather than a flat wash — the parenting hero read as bland
        // next to it.
        Positioned(
          right: -44,
          top: -48,
          child: Container(width: 168, height: 168, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.10))),
        ),
        Positioned(
          left: -30,
          bottom: -54,
          child: Container(width: 132, height: 132, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06))),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // The "How <name> is today" line moved OUT of this card and above it,
        // as a page-level eyebrow — see _heroEyebrow(). It matches the pregnancy
        // home, where "WEEKLY SNAPSHOT" labels the hero from outside rather than
        // greeting from within.
        // ---- identity + leap (removed: "LIVE NOW", the "Curious Explorer"
        //      character line, the storm→sun progress bar and its status
        //      sentence — none carried real information) ---------------------
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          GestureDetector(
            onTap: () => showMultiChildSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: const PpStriped(height: 56),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => showMultiChildSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(
                    child: Text(_child.name,
                        style: ppFraunces(25, color: Colors.white, h: 1.05),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: w70),
                ]),
              ),
              const SizedBox(height: 3),
              Text('${phase.ageLabel} · ${phase.name}',
                  style: ppBody(12.5, color: Colors.white.withValues(alpha: 0.9), w: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          // The leap page is now reached by this quieter chip rather than the
          // whole card being one tap target (the card holds interactive growth
          // controls now, so a card-wide tap would fight them).
          GestureDetector(
            onTap: () => _push(PhaseDetailScreen(phase: phase)),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('This phase', style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
              ]),
            ),
          ),
        ]),

        // ---- the leap journey bar (in-hero) ----------------------------------
        // The parenting answer to the pregnancy trimester bar: where the child
        // is across the WHOLE leap journey (Leap N of 10), not the meaningless
        // day-progress the old bar showed. The current dot also tells you the
        // one thing a Wonder-Weeks parent cares about most — fussy leap now, or
        // a calm stretch between leaps.
        const SizedBox(height: 15),
        _phaseJourneyLegacy(phase),

        // ---- growth, folded into the hero ------------------------------------
        // REVISED 18 Jul: growth stays INSIDE the hero card but reads as its own
        // thing rather than more of the same wash — a darker inset panel with
        // its own rounded edge. Same box, visibly a different register, so the
        // numbers do not blur into the leap copy above them.
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('GROWTH', style: ppBody(10.5, color: w70, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
              const Spacer(),
              _heroAction(Icons.edit_outlined, 'Edit', _openGrowthEdit),
              const SizedBox(width: 14),
              _heroAction(Icons.show_chart_rounded, 'Chart', () => _push(const GrowthJourneyScreen())),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _heroStat('Weight', _m(_child.weightKg, 1), 'kg', '~${e.weightKg.toStringAsFixed(1)}')),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.18)),
              Expanded(child: _heroStat('Height', _m(_child.heightCm, 0), 'cm', '~${e.heightCm.toStringAsFixed(0)}')),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.18)),
              Expanded(child: _heroStat('Head', _m(_child.headCm, 0), 'cm', '~${e.headCm.toStringAsFixed(0)}')),
            ]),
          ]),
        ),
          ]),
        ),
      ]),
    ));
  }

  Widget _heroAction(IconData icon, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: ppBody(11.5, color: Colors.white, w: FontWeight.w700)),
        ]),
      );

  // OPTION 1 — the leap journey as its own slim card below the hero. Trialled
  // against the in-hero version; the in-hero one won, so this is kept only for
  // revert and is not mounted.
  // ignore: unused_element
  Widget _leapJourneyStrip(Leap leap) {
    const total = 10;
    const fussy = Color(0xFFC98A2B); // amber, tuned for a light background
    final age = _child.ageInWeeks;
    final idx = currentLeapIndex(age);
    final inLeap = age >= leap.startWeek && age <= leap.endWeek;
    final next = nextLeap(_child);
    final state = inLeap ? fussy : ppPurple;

    final String status;
    if (inLeap) {
      status = next != null
          ? 'A fussy stretch now, calm before Leap ${next.number}.'
          : 'A fussy stretch now.';
    } else {
      status = next != null
          ? 'A calm stretch, next leap around week ${next.startWeek.round()}.'
          : 'Past the last big leap.';
    }

    return ppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: () => _push(const LeapCalendarScreen()),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('LEAP JOURNEY', style: ppBody(10.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
          const Spacer(),
          Text('Leap ${leap.number} of $total', style: ppBody(11, color: ppPurple, w: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0)
              Expanded(child: Container(height: 2, color: i <= idx ? ppPurple.withValues(alpha: 0.45) : ppHair)),
            _leapDotLight(i, idx, state),
          ],
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: state, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(status, style: ppBody(12.5, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
        ]),
      ]),
    );
  }

  Widget _leapDotLight(int i, int idx, Color state) {
    if (i == idx) {
      return Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          color: state,
          shape: BoxShape.circle,
          border: Border.all(color: state.withValues(alpha: 0.28), width: 3),
        ),
      );
    }
    final past = i < idx;
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: past ? ppPurple : ppHair,
        shape: BoxShape.circle,
      ),
    );
  }

  // The leap-journey bar (white-on-purple, in the hero). Ten stops; past leaps
  // filled, the current one lit and coloured by state, future ones hollow.
  // OPTION 2 — the LIVE version, mounted inside _leapHero (line ~297). Tapping
  // the whole bar opens the Leap Calendar (the full "view timeline"); the
  // "Leap N of 10 ›" chevron is the affordance. The below-hero alternative,
  // _leapJourneyStrip, is the commented one.
  //  THE PHASE JOURNEY BAR — a continuous 0–5 year track.
  //
  //  It replaced a 10-dot "Leap 4 of 10" strip. Dots could not survive the move
  //  to age phases: the phases are deliberately uneven (one month early on,
  //  twelve months at the end), so equal-sized dots would tell a parent that a
  //  newborn month and a whole preschool year are the same distance. A
  //  continuous bar is the honest shape — it shows WHERE he is on the road,
  //  not which numbered stop he is standing at.
  //
  //  Tapping opens the full phase map.
  // SUPERSEDED 21 Jul by the _phaseJourney below. Kept, unmounted, for revert.
  // ignore: unused_element
  Widget _phaseJourneyLegacy(AgePhase phase) {
    const w70 = Color(0xB3FFFFFF);
    final progress = journeyProgress(_child);
    final next = nextPhase(_child);

    final String status;
    if (next != null) {
      status = 'Next: ${next.name.toLowerCase()}, around ${next.ageLabel}.';
    } else {
      status = 'The last stretch before school.';
    }

    return GestureDetector(
      onTap: () => _push(const PhaseMapScreen()),
      behavior: HitTestBehavior.opaque,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('HIS JOURNEY', style: ppBody(10.5, color: w70, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
          const Spacer(),
          // The PHASE, not the age. The identity row above already carries
          // "<age> · <phase>", so repeating ageLabel here said "3 months" twice
          // in one card and never named the phase in full. This bar tracks
          // progress through the phases, so the phase is what should label it.
          Flexible(
            child: Text(phase.name,
                style: ppBody(10.5, color: Colors.white, w: FontWeight.w800),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right_rounded, size: 15, color: w70),
        ]),
        const SizedBox(height: 11),
        // The track. Birth on the left, five years on the right, a marker where
        // he actually is.
        LayoutBuilder(builder: (context, c) {
          final x = (c.maxWidth - 14) * progress;
          return SizedBox(
            height: 14,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: 0,
                right: 0,
                top: 6,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 6,
                child: Container(
                  width: x + 7,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                left: x,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: phase.accent, width: 3),
                  ),
                ),
              ),
            ]),
          );
        }),
        const SizedBox(height: 7),
        Row(children: [
          Text('Birth', style: ppBody(10.5, color: w70, w: FontWeight.w700)),
          const Spacer(),
          Text('5 years', style: ppBody(10.5, color: w70, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(status, style: ppBody(11.5, color: Colors.white.withValues(alpha: 0.9)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ]),
    );
  }

  // RETIRED with the leap framework — the 10-dot strip. Kept for revert.
  // ignore: unused_element
  Widget _leapJourney(Leap leap) {

    const total = 10; // kLeaps.length
    const w70 = Color(0xB3FFFFFF);
    const fussy = Color(0xFFFFC24B); // amber — a fussy leap window
    final age = _child.ageInWeeks;
    final idx = currentLeapIndex(age);
    final inLeap = age >= leap.startWeek && age <= leap.endWeek;
    final next = nextLeap(_child);

    final String status;
    if (inLeap) {
      status = next != null
          ? 'A fussy stretch now, calm before Leap ${next.number}.'
          : 'A fussy stretch now.';
    } else {
      status = next != null
          ? 'A calm stretch, next leap around week ${next.startWeek.round()}.'
          : 'Past the last big leap.';
    }

    return GestureDetector(
      onTap: () => _push(const LeapCalendarScreen()),
      behavior: HitTestBehavior.opaque,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('LEAP JOURNEY', style: ppBody(10.5, color: w70, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
          const Spacer(),
          Text('Leap ${leap.number} of $total', style: ppBody(10.5, color: Colors.white, w: FontWeight.w800)),
          // Makes it evident the whole bar is tappable — opens the full timeline.
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right_rounded, size: 15, color: w70),
        ]),
        const SizedBox(height: 11),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(height: 2, color: Colors.white.withValues(alpha: i <= idx ? 0.55 : 0.20)),
              ),
            _leapDot(i, idx, inLeap ? fussy : Colors.white),
          ],
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: inLeap ? fussy : Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(status, style: ppBody(11.5, color: Colors.white.withValues(alpha: 0.9)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ]),
    );
  }

  Widget _leapDot(int i, int idx, Color currentColor) {
    if (i == idx) {
      // Current leap: a larger, ringed dot in the state colour.
      return Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
        ),
      );
    }
    final past = i < idx;
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: past ? Colors.white : Colors.white.withValues(alpha: 0.28),
        shape: BoxShape.circle,
      ),
    );
  }

  /// A growth stat rendered white-on-purple for the hero.
  Widget _heroStat(String label, String value, String unit, String expected) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label.toUpperCase(),
              style: ppBody(10.5, color: Colors.white.withValues(alpha: 0.7), w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: ppFraunces(19, color: Colors.white, h: 1.0)),
              TextSpan(text: ' $unit', style: ppBody(10.5, color: Colors.white.withValues(alpha: 0.85), w: FontWeight.w600)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text('exp $expected', style: ppBody(10.5, color: Colors.white.withValues(alpha: 0.65)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );

  // =========================================================================
  //  Leap header (the header, like the leap page)
  //  RETIRED — folded into _leapHero above. Kept for revert.
  // =========================================================================
  // ignore: unused_element
  Widget _leapHeader(Leap leap) {
    final prog = leapProgress(_child);
    final a = leap.accent;
    return _pad(GestureDetector(
      onTap: () => _push(LeapDefinitionScreen(leap: leap)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a, Color.lerp(a, Colors.black, 0.32)!]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: a.withValues(alpha: 0.32), blurRadius: 28, spreadRadius: -12, offset: const Offset(0, 14))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('LIVE NOW', style: ppBody(10.5, color: Colors.white.withValues(alpha: 0.9), w: FontWeight.w700).copyWith(letterSpacing: 1.0)),
            Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Flexible(child: Text('Read about this leap', style: ppBody(11.5, color: Colors.white.withValues(alpha: 0.9), w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward, size: 13, color: Colors.white),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Text('${_child.name.toUpperCase()} IS IN', style: ppBody(10.5, color: Colors.white.withValues(alpha: 0.8), w: FontWeight.w700).copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(leap.label, style: ppFraunces(34, color: Colors.white, h: 1.0)),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(leap.name, style: ppBody(14, color: Colors.white.withValues(alpha: 0.92)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          // storm → sunny progress
          Row(children: [
            const Icon(Icons.cloud_rounded, size: 15, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Stack(children: [
                Container(height: 7, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(999))),
                FractionallySizedBox(widthFactor: prog.clamp(0.05, 1.0), child: Container(height: 7, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)))),
              ]),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.wb_sunny_rounded, size: 15, color: Colors.white),
          ]),
          const SizedBox(height: 8),
          Text(prog > 0.5 ? 'Past the worst - brighter days ahead.' : 'Early days of this leap - extra closeness helps.',
              style: ppBody(11.5, color: Colors.white.withValues(alpha: 0.85))),
        ]),
      ),
    ));
  }

  // =========================================================================
  //  Identity (photo + name + current-leap character)
  //  RETIRED — folded into _leapHero above. Kept for revert.
  // =========================================================================
  // ignore: unused_element
  Widget _identity(Leap leap) => _pad(Row(children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5), boxShadow: const [BoxShadow(color: Color(0x226A30B6), blurRadius: 14, offset: Offset(0, 6))]),
          clipBehavior: Clip.antiAlias,
          child: const PpStriped(height: 72),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome, size: 13, color: ppCoral),
              const SizedBox(width: 6),
              Flexible(child: ppEyebrow(leap.character, color: ppCoral, spacing: 1.0)),
            ]),
            const SizedBox(height: 6),
            Text(_child.name, style: ppFraunces(30, h: 1.05)),
          ]),
        ),
      ]));

  // =========================================================================
  //  Growth (inline, with expected-for-age + Edit)
  // =========================================================================
  //  Growth is now folded into the leap hero (see _leapHero) with its own Edit
  //  and Chart controls, so this standalone section is retired. Kept for revert.
  //  ignore: unused_element
  Widget _growth() {
    final e = _child.expected;
    return _pad(ppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Growth', style: ppJakarta(15))),
          GestureDetector(
            onTap: _openGrowthEdit,
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.edit_outlined, size: 14, color: ppPurple),
              const SizedBox(width: 4),
              Text('Edit', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => _push(const GrowthJourneyScreen()),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Chart', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
              const SizedBox(width: 3),
              const Icon(Icons.arrow_forward, size: 13, color: ppPurple),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _growthStat('Weight', _m(_child.weightKg, 1), 'kg', '~${e.weightKg.toStringAsFixed(1)}')),
          _statDivider(),
          Expanded(child: _growthStat('Height', _m(_child.heightCm, 0), 'cm', '~${e.heightCm.toStringAsFixed(0)}')),
          _statDivider(),
          Expanded(child: _growthStat('Head', _m(_child.headCm, 0), 'cm', '~${e.headCm.toStringAsFixed(0)}')),
        ]),
      ]),
    ));
  }

  Widget _statDivider() => Container(width: 1, height: 34, color: ppHair);

  /// One measurement, with the typical figure for the child's age beneath it.
  Widget _growthStat(String label, String value, String unit, String expected) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label.toUpperCase(),
              style: ppBody(10.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: ppJakarta(19)),
              TextSpan(text: ' $unit', style: ppBody(10.5, color: ppSoft, w: FontWeight.w600)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text('exp $expected', style: ppBody(10.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );

  // The old three-tile growth block. Kept for revert.
  // ignore: unused_element
  Widget _growthOld() {
    final e = _child.expected;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(Row(children: [
        Expanded(child: Text('Growth', style: ppJakarta(16))),
        GestureDetector(
          onTap: _openGrowthEdit,
          behavior: HitTestBehavior.opaque,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.edit_outlined, size: 15, color: ppPurple),
            const SizedBox(width: 5),
            Text('Edit', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ]),
        ),
      ])),
      const SizedBox(height: 4),
      _pad(Text('His measurements, with the typical figure for a ${_child.ageInMonths}-month-old alongside.', style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 14),
      _pad(Row(children: [
        Expanded(child: _growthCard('Weight', _m(_child.weightKg, 1), 'kg', '~${e.weightKg.toStringAsFixed(1)} kg')),
        const SizedBox(width: 12),
        Expanded(child: _growthCard('Height', _m(_child.heightCm, 0), 'cm', '~${e.heightCm.toStringAsFixed(0)} cm')),
        const SizedBox(width: 12),
        Expanded(child: _growthCard('Head', _m(_child.headCm, 0), 'cm', '~${e.headCm.toStringAsFixed(0)} cm')),
      ])),
      const SizedBox(height: 14),
      _pad(GestureDetector(
        onTap: () => _push(const GrowthJourneyScreen()),
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Flexible(child: Text('View detailed growth chart', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
        ]),
      )),
    ]);
  }

  Widget _growthCard(String label, String value, String unit, String expected) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: ppBody(10.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: ppJakarta(20)),
              TextSpan(text: ' $unit', style: ppBody(11.5, color: ppSoft, w: FontWeight.w600)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text('exp $expected', style: ppBody(10.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  // =========================================================================
  //  Hero eyebrow — the pregnancy home's "WEEKLY SNAPSHOT" treatment
  // =========================================================================
  //  Mirrors _sectionEyebrow in home_screen_b.dart exactly: Manrope 11.5 / w800
  //  / 1.0 letter-spacing / uppercase / brand purple, nudged 4px in and 2px off
  //  the card below it. Keeping the numbers identical is the point — this is the
  //  one label both apps use to introduce their hero, so it must look like one
  //  label, not two that happen to rhyme.
  Widget _heroEyebrow() => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 2),
        child: Text('How ${_child.name} is today'.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: ppPurple)),
      );

  // =========================================================================
  //  Daily tip
  // =========================================================================
  //  Tinted rather than white, the way the pregnancy HomeCard marks a
  //  highlighted module — same card shell, one accent wash.
  //  Today's Parenting Tip — a faithful copy of the pregnancy home's GrowModule
  //  card (a HomeCard): the "TODAY'S PARENTING TIP" eyebrow with the leaf icon,
  //  the tip title in quotes, the body as the one-line hook, and a full-width
  //  "Read more" button. It must read, unmistakably, as *today's tip*.
  //  Content unchanged: still whatever dailyTip() returns.
  //  REVISED 21 Jul: rebuilt as a FAITHFUL MATCH of the pregnancy home's
  //  GrowModule (widgets/home/home_modules.dart), which carries the identical
  //  "TODAY'S PARENTING TIP" eyebrow on that side. Every number below is copied
  //  from HomeCard + GrowModule rather than approximated:
  //
  //    padding   20/18/20/20        (HomeCard)
  //    eyebrow   icon 16 + 7 gap, labelSmall 11 / w800 / 1.1 tracking, accent
  //    title     10 gap, headlineSmall = Jakarta 20 / w600, wrapped in quotes
  //    body      12 gap, bodyLarge = Manrope 16 / w600 / 1.5 height
  //    button    16 gap, FULL-WIDTH primary with trailing arrow
  //
  //  Two earlier versions were wrong in opposite directions: first 70% wide and
  //  centred (adrift, and empty inside), then full-width but shrunk to 14.5/12.5
  //  with a bare text link — still a footnote next to pregnancy's featured read.
  //  The pregnancy card treats the daily tip as editorial. This is the same
  //  content in the same role, so it gets the same weight.
  Widget _dailyTip() {
    final t = dailyTip();
    return _pad(ppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.eco_rounded, size: 16, color: ppPurple),
          const SizedBox(width: 7),
          Expanded(
            child: Text("TODAY'S PARENTING TIP",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                    fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: ppPurple)),
          ),
        ]),
        const SizedBox(height: 10),
        // Quoted, exactly as GrowModule quotes its title.
        Text('“${t.title}”', style: ppJakarta(20, w: FontWeight.w600)),
        const SizedBox(height: 12),
        Text(t.body, style: ppBody(16, color: ppInk, h: 1.5, w: FontWeight.w600)),
        const SizedBox(height: 16),
        // Full-width primary action — the pregnancy HomePrimaryButton, in pp
        // purple. A quiet text link was the main reason this card read as minor.
        GestureDetector(
          onTap: () => _openTipSheet(t),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Read more',
                  style: GoogleFonts.manrope(
                      fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: Colors.white)),
              const SizedBox(width: 7),
              const Icon(Icons.arrow_forward_rounded, size: 17, color: Colors.white),
            ]),
          ),
        ),
      ]),
    ));
  }

  void _openTipSheet(DailyTip t) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: ppBg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 18),
            Row(children: [
              const Icon(Icons.eco_rounded, size: 15, color: ppPurple),
              const SizedBox(width: 7),
              ppEyebrow("Today's parenting tip", color: ppPurple),
            ]),
            const SizedBox(height: 12),
            Text('“${t.title}”', style: ppFraunces(23, color: ppTitleInk)),
            const SizedBox(height: 12),
            Text(t.body, style: ppBody(15, color: ppInk, h: 1.65)),
          ]),
        ),
      );

  // =========================================================================
  //  Leap video
  // =========================================================================
  //  Modelled on the pregnancy home's "Today's Video" card: a header row inside
  //  the card (title + "More videos"), then the thumbnail, title, a why-line
  //  and a Watch button.
  //
  //  The video is now chosen from the PHASE's Watch category rather than from a
  //  hardcoded id on each leap — ten hand-picked ids do not survive becoming
  //  twenty phases, and picking by category keeps it in step with the catalogue.
  Widget _leapVideo(AgePhase phase) {
    final cat = watchCategoryForPhase(phase);
    final pool = watchByCategory(cat);
    if (pool.isEmpty) return const SizedBox.shrink();
    final v = pool.first;
    final a = phase.accent;
    void open() => _push(v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v));
    return _pad(Container(
      decoration: ppCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            const Icon(Icons.play_circle_outline_rounded, size: 16, color: ppPurple),
            const SizedBox(width: 7),
            Expanded(child: Text('This phase, in a video', style: ppJakarta(16))),
            GestureDetector(
              onTap: () => _push(WatchCategoryScreen(category: cat)),
              behavior: HitTestBehavior.opaque,
              child: Text('More videos', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: GestureDetector(
            onTap: open,
            behavior: HitTestBehavior.opaque,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a.withValues(alpha: 0.85), Color.lerp(a, Colors.black, 0.3)!])),
                  alignment: Alignment.center,
                  child: Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle), child: Icon(Icons.play_arrow_rounded, size: 30, color: a)),
                ),
              ),
              const SizedBox(height: 12),
              Text(v.title, style: ppJakarta(16)),
              const SizedBox(height: 6),
              Text('${v.durationLabel} · ${v.expert.name}', style: ppBody(12.5, color: ppMuted, h: 1.4)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: ppPurple,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: open,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
                  label: Text('Watch', style: ppBody(14, color: Colors.white, w: FontWeight.w800)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    ));
  }

  // =========================================================================
  //  Leap description (expandable)
  // =========================================================================
  Widget _leapDescription(AgePhase phase) => _pad(ppSectionCard(
        eyebrow: 'This phase explained',
        icon: Icons.auto_awesome_outlined,
        title: 'What ${phase.ageLabel} looks like',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(phase.summary, style: ppBody(14.5, color: ppInk, h: 1.65)),
          if (_leapExpanded)
            for (final s in phase.sections) ...[
              const SizedBox(height: 16),
              Text(s.heading, style: ppJakarta(15)),
              const SizedBox(height: 8),
              for (final p in s.paragraphs) ...[
                Text(p, style: ppBody(14, color: ppInk, h: 1.6)),
                const SizedBox(height: 10),
              ],
            ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _leapExpanded = !_leapExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              Flexible(child: Text(_leapExpanded ? 'Show less' : 'Read the full description', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 5),
              Icon(_leapExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 19, color: ppPurple),
            ]),
          ),
        ]),
      ));

  // =========================================================================
  //  Child snapshot (five domains - unchanged layout)
  // =========================================================================
  Widget _snapshot() {
    final cards = <(IconData, String, String, String, String, VoidCallback)>[
      (Icons.psychology_outlined, 'Brain', 'Cause & effect', 'Following your hand all the way to the toy it reaches for.', 'Developing', () => _push(DevelopmentAreaScreen(area: devAreaById('cognitive')))),
      (Icons.child_care_outlined, 'Physical', 'Rolling & reaching', 'Hands clasp at his chest and he pushes up. A first roll any day now.', 'Emerging', () => _push(DevelopmentAreaScreen(area: devAreaById('gross_motor')))),
      (Icons.chat_bubble_outline_rounded, 'Language', 'Musical babble', "Coos stretching into 'aah-goo', raspberries and squeals.", 'Emerging', () => _push(DevelopmentAreaScreen(area: devAreaById('language')))),
      (Icons.favorite_border, 'Emotional', 'Social joy', 'Beams at you across a room; a laugh now earns a laugh back.', 'Blossoming', () => _push(DevelopmentAreaScreen(area: devAreaById('emotional')))),
      (Icons.restaurant_outlined, 'Nutrition', 'Milk is everything', 'Solids open up around 6 months, a few weeks away yet.', 'On track', () => _push(const NutritionScreen())),
    ];
    return _pad(ppSectionCard(
      eyebrow: 'Child snapshot',
      icon: Icons.insights_rounded,
      title: 'How ${_child.name} is doing',
      child: Column(children: [
        for (final c in cards) ...[
          if (c != cards.first) ppRowDivider(),
          _snapRow(c.$1, c.$2, c.$3, c.$4, c.$5, c.$6),
        ],
      ]),
    ));
  }

  // A flat domain row inside the snapshot card (was a floating sub-card; a card
  // of cards read as clutter next to the pregnancy home's single-card sections).
  Widget _snapRow(IconData icon, String domain, String stage, String insight, String status, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 18, color: ppPurple)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(domain.toUpperCase(), style: ppBody(10.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 2),
                  Text(stage, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const SizedBox(width: 10),
              _statusPill(status),
            ]),
            const SizedBox(height: 9),
            Text(insight, style: ppBody(12.5, h: 1.5)),
            // The rows always opened a domain page, but nothing said so. This
            // is the quietest affordance that still reads as tappable: a small
            // muted "Explore <domain> ›" under the insight. Deliberately not a
            // button - it should whisper, not compete with the content.
            const SizedBox(height: 7),
            Row(children: [
              Text('Explore $domain', style: ppBody(11.5, color: ppPurple, w: FontWeight.w700)),
              const SizedBox(width: 3),
              const Icon(Icons.chevron_right_rounded, size: 15, color: ppPurple),
            ]),
          ]),
        ),
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'Developing':
      case 'Mastered':
        return ppPurple;
      case 'Blossoming':
      case 'Current focus':
        return ppCoral;
      case 'Emerging':
      case 'Coming next':
        return const Color(0xFFC98A2B);
      default:
        return ppSoft;
    }
  }

  Widget _statusPill(String status) {
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: ppBody(11, color: c, w: FontWeight.w700)),
    );
  }

  // =========================================================================
  //  Milestones (current + emerging, each opens its detail)
  // =========================================================================
  //  REFRAMED 18 Jul. This used to be "Milestones", showing both what he is
  //  doing NOW and what is next — which made it near-indistinguishable from the
  //  Child snapshot directly above it. Two sections answering the same question
  //  is one section too many.
  //
  //  It now answers a question nothing else does: WHAT IS COMING, and how do I
  //  help him get there. Only 'next' stages appear; the "now" story belongs to
  //  the snapshot. Each row opens the milestone detail, where the preparation
  //  actually lives.
  Widget _milestones() {
    final areas = ['gross_motor', 'cognitive', 'language', 'emotional'].map(devAreaById).toList();
    final rows = <(DevArea, DevStage)>[];
    for (final area in areas) {
      for (final s in area.journey.where((s) => s.status == 'next')) {
        rows.add((area, s));
      }
    }
    return _pad(ppSectionCard(
      eyebrow: 'Coming up',
      icon: Icons.trending_up_rounded,
      accent: ppCoral,
      title: "What ${_child.name} is preparing for next",
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'None of this is due yet. Knowing what is around the corner is how you help him get there — open any one for ways to prepare.',
            style: ppBody(12.5, color: ppSoft, h: 1.5),
          ),
        ),
        for (final r in rows) ...[
          ppRowDivider(),
          _milestoneRow(r.$1, r.$2),
        ],
      ]),
    ));
  }

  Widget _milestoneRow(DevArea area, DevStage s) {
    final now = s.status == 'current';
    final a = area.accent;
    return GestureDetector(
      onTap: () => _push(DevStageDetailScreen(area: area, stage: s, kindLabel: 'Milestone')),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: a.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(area.icon, size: 19, color: a)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(s.name, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                // The section is now "what's next" only, so a NOW/NEXT tag says
                // nothing. The area name is the useful label - it tells her
                // WHICH part of him this belongs to. Flexible + ellipsis: under
                // a wide accessibility font this and the skill name compete.
                Flexible(
                  child: Text(area.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ppBody(10.5, color: now ? ppCoral : const Color(0xFFC98A2B), w: FontWeight.w800).copyWith(letterSpacing: 0.5)),
                ),
              ]),
              const SizedBox(height: 2),
              Text(s.meaning, style: ppBody(12.5, color: ppSoft, h: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }

  // =========================================================================
  //  Products for this leap (after the watch/read rails)
  // =========================================================================
  //  Deliberately a MIX rather than one category: picks that suit his age and
  //  what he is working on, drawn from across the catalogue. The rails above
  //  are about understanding; this is the one place on the page that is about
  //  buying, and it sits last for that reason.
  Widget _leapProducts(AgePhase phase) {
    final picks = recommendedToday(count: 8);
    if (picks.isEmpty) return const SizedBox.shrink();
    return _pad(ppCarousel(
      accent: phase.accent,
      icon: Icons.shopping_bag_outlined,
      title: 'Picks for this phase',
      seeAll: 'View more',
      onSeeAll: () => _push(const RecommendationsScreen()),
      railHeight: 176,
      items: [
        for (final r in picks)
          GestureDetector(
            onTap: () => _push(RecoDetailScreen(item: r)),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 152,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(color: phase.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Icon(Icons.card_giftcard_rounded, size: 26, color: phase.accent)),
                ),
                const SizedBox(height: 8),
                Text(r.title, style: ppJakarta(13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Expanded(
                  child: Text(r.why, style: ppBody(11.5, color: ppSoft, h: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
          ),
      ],
    ));
  }

  // =========================================================================
  //  FAQs for this leap
  // =========================================================================
  //  Three questions, rotating each app launch so a daily visitor meets the
  //  whole pool over a week. Ask Veda closes it off for anything not covered —
  //  the honest admission that three answers will not cover a real 3am worry.
  Widget _faqs(AgePhase phase) {
    final faqs = phaseFaqs(phase.number);
    if (faqs.isEmpty) return const SizedBox.shrink();
    return _pad(ppSectionCard(
      eyebrow: 'Questions parents ask',
      icon: Icons.help_outline_rounded,
      title: 'About this phase',
      child: Column(children: [
        for (var i = 0; i < faqs.length; i++) ...[
          if (i > 0) ppRowDivider(),
          _faqRow(faqs[i], i),
        ],
        ppRowDivider(),
        GestureDetector(
          onTap: () => _push(const AskVedaScreen()),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.auto_awesome_rounded, size: 17, color: ppPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Ask Veda anything else',
                    style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppPurple),
            ]),
          ),
        ),
      ]),
    ));
  }

  Widget _faqRow(PhaseFaq f, int i) {
    final open = _faqOpen == i;
    return GestureDetector(
      onTap: () => setState(() => _faqOpen = open ? -1 : i),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(f.question, style: ppJakarta(15))),
            const SizedBox(width: 10),
            Icon(open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 20, color: ppMuted),
          ]),
          AnimatedSize(
            duration: const Duration(milliseconds: 160),
            alignment: Alignment.topCenter,
            // Conditional child, not a cross-fade: a collapsed answer that is
            // still in the tree gets read aloud by screen readers.
            child: open
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(f.answer, style: ppBody(12.5, h: 1.55)),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ]),
      ),
    );
  }

  // =========================================================================
  //  Journal (capture flows + storybook)
  // =========================================================================
  Widget _journal() {
    final tiles = <(IconData, String, VoidCallback)>[
      (Icons.auto_awesome_outlined, 'Guided memory', () => _push(const GuidedMemoryScreen())),
      (Icons.bolt_outlined, 'Quick capture', () => _push(const QuickCaptureScreen())),
      (Icons.edit_note_outlined, 'Write a story', () => _push(const WriteStoryScreen())),
      (Icons.mail_outline_rounded, 'Letter to ${_child.name}', () => _push(const LetterScreen())),
    ];
    return _pad(ppSectionCard(
      eyebrow: 'Journal',
      icon: Icons.menu_book_outlined,
      accent: ppBrown,
      title: 'Moments worth keeping',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          for (int i = 0; i < 2; i++) ...[
            Expanded(child: _journalTile(tiles[i].$1, tiles[i].$2, tiles[i].$3)),
            if (i == 0) const SizedBox(width: 12),
          ],
        ]),
        const SizedBox(height: 12),
        Row(children: [
          for (int i = 2; i < 4; i++) ...[
            Expanded(child: _journalTile(tiles[i].$1, tiles[i].$2, tiles[i].$3)),
            if (i == 2) const SizedBox(width: 12),
          ],
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _push(const StorybookReaderScreen()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.auto_stories_outlined, size: 19, color: ppPurple),
              const SizedBox(width: 12),
              Expanded(child: Text("Preview ${_child.name}'s storybook…", style: ppBody(14, color: ppInk, w: FontWeight.w600))),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
            ]),
          ),
        ),
      ]),
    ));
  }

  Widget _journalTile(IconData icon, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // Flat panel tiles rather than white+border, so they don't read as
        // cards floating inside the Journal card.
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(width: 34, height: 34, alignment: Alignment.center, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, size: 17, color: ppPurple)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: ppBody(12.5, color: ppInk, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );

  // =========================================================================
  //  Leap-related Watch rail
  // =========================================================================
  Widget _leapWatch(AgePhase phase) {
    final cat = watchCategoryForPhase(phase);
    final videos = watchByCategory(cat);
    if (videos.isEmpty) return const SizedBox.shrink();
    // The pregnancy home's product-carousel shape: a gradient header band +
    // a compact rail, which packs the same content into much less height than
    // the loose eyebrow + title + rail the parenting side had.
    return _pad(ppCarousel(
      accent: phase.accent,
      icon: Icons.play_circle_outline_rounded,
      title: 'Videos for this phase',
      seeAll: 'View more',
      onSeeAll: () => _push(WatchCategoryScreen(category: cat)),
      railHeight: 180,
      items: [
        for (final v in videos)
          GestureDetector(
            onTap: () => _push(v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v)),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 160,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: 84, decoration: BoxDecoration(color: phase.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(Icons.play_circle_outline, size: 28, color: phase.accent))),
                const SizedBox(height: 8),
                Text(v.title, style: ppJakarta(13).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${v.durationLabel} · ${v.expert.name}', style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
      ],
    ));
  }

  // =========================================================================
  //  Leap-related Learn rail
  // =========================================================================
  Widget _leapLearn(AgePhase phase) {
    final colId = readCollectionForPhase(phase);
    final reads = articlesInCollection(colId);
    if (reads.isEmpty) return const SizedBox.shrink();
    return _pad(ppCarousel(
      accent: phase.accent,
      icon: Icons.menu_book_outlined,
      title: 'Reads for this phase',
      seeAll: 'View more',
      onSeeAll: () => _push(ReadingCollectionScreen(collection: readCollectionById(colId))),
      railHeight: 180,
      items: [
        for (final a in reads)
          GestureDetector(
            onTap: () => _push(ReadingReaderScreen(article: a)),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 160,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: 84, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.menu_book_outlined, size: 26, color: ppPurple))),
                const SizedBox(height: 8),
                Text(a.title, style: ppJakarta(13).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${a.minutes} min · ${a.author}', style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
      ],
    ));
  }

  // =========================================================================
  //  Looking ahead (one line → next leap)
  // =========================================================================
  Widget _lookingAhead() {
    final next = nextPhase(_child);
    if (next == null) return const SizedBox.shrink();
    return _pad(GestureDetector(
      onTap: () => _push(PhaseDetailScreen(phase: next)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Row(children: [
          Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: next.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.brightness_4_rounded, size: 19, color: next.accent)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LOOKING AHEAD', style: ppBody(10.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
              const SizedBox(height: 3),
              Text('${next.ageLabel} · ${next.name}', style: ppBody(13, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    ));
  }

  // =========================================================================
  //  Timelines — Memory (journal) + Health, at the bottom of the home
  //  RETIRED 18 Jul: the home is about now, not a scroll through history. Both
  //  timelines live on in Journal and Health. Kept for revert.
  // =========================================================================
  // ignore: unused_element
  Widget _timelines() => _pad(ppSectionCard(
        eyebrow: 'Timelines',
        icon: Icons.timeline_rounded,
        accent: const Color(0xFF3E9A8C),
        child: Column(children: [
          _timelineRow(Icons.auto_stories_outlined, 'Memory timeline',
              "${_child.name}'s journal, moment by moment", () => _push(const JournalV2Home())),
          ppRowDivider(),
          _timelineRow(Icons.monitor_heart_outlined, 'Health timeline',
              'Growth, visits & vaccines in one place', () => _push(const HealthTimelineScreen())),
        ]),
      ));

  Widget _timelineRow(IconData icon, String title, String sub, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 18, color: ppPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppJakarta(15)),
                const SizedBox(height: 2),
                Text(sub, style: ppBody(12.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  // ---- section header -----------------------------------------------------
  //  RETIRED — every section is now a ppSectionCard whose header lives inside
  //  the card. Kept for revert.
  // ignore: unused_element
  Widget _header(String eyebrow, String title, {String? sub}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow(eyebrow, color: ppPurple, spacing: 1.2),
        const SizedBox(height: 5),
        Text(title, style: ppJakarta(19)),
        if (sub != null) ...[
          const SizedBox(height: 4),
          Text(sub, style: ppBody(13, h: 1.5)),
        ],
      ]);

  // A measurement of 0 means NOT RECORDED, not "zero kilos". Display shows a
  // dash so we never assert a figure the parent has not given us; the edit
  // fields show a blank so she is typing into an empty box, not over a fake
  // number. (The seeded child used to carry 6.4 kg / 63 cm / 41 cm.)
  static String _m(double v, int dp) =>
      ChildProfileStore.hasValue(v) ? v.toStringAsFixed(dp) : '—';
  static String _edit(double v, int dp) =>
      ChildProfileStore.hasValue(v) ? v.toStringAsFixed(dp) : '';

  // ---- growth / profile edit sheet ----------------------------------------
  Future<void> _openGrowthEdit() async {
    final nameCtl = TextEditingController(text: _child.name);
    final wCtl = TextEditingController(text: _edit(_child.weightKg, 1));
    final hCtl = TextEditingController(text: _edit(_child.heightCm, 0));
    final headCtl = TextEditingController(text: _edit(_child.headCm, 0));
    DateTime dob = _child.dob;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Text('Edit profile & growth', style: ppJakarta(19)),
                const SizedBox(height: 18),
                _field('Name', nameCtl),
                const SizedBox(height: 14),
                // date of birth
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dob,
                      firstDate: DateTime(2018),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setSheet(() => dob = picked);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
                    child: Row(children: [
                      const Icon(Icons.cake_outlined, size: 18, color: ppPurple),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Date of birth', style: ppBody(14, color: ppInk, w: FontWeight.w600))),
                      Text('${dob.day} ${_monthsShort[dob.month - 1]} ${dob.year}', style: ppBody(13, color: ppSoft)),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _field('Weight (kg)', wCtl, number: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Height (cm)', hCtl, number: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Head (cm)', headCtl, number: true)),
                ]),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () {
                    _child.update(
                      name: nameCtl.text,
                      dob: dob,
                      weightKg: double.tryParse(wCtl.text.trim()),
                      heightCm: double.tryParse(hCtl.text.trim()),
                      headCm: double.tryParse(headCtl.text.trim()),
                    );
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                    child: Text('Save', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
    nameCtl.dispose();
    wCtl.dispose();
    hCtl.dispose();
    headCtl.dispose();
  }

  Widget _field(String label, TextEditingController ctl, {bool number = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
            child: TextField(
              controller: ctl,
              keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              style: ppBody(14.5, color: ppInk, w: FontWeight.w600),
              decoration: const InputDecoration(
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      );
}

const List<String> _monthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
