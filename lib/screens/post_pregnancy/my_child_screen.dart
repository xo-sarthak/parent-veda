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
import 'recipes_screen.dart';
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
import 'pp_reading_data.dart';
import 'pp_watch_data.dart';
import 'reading_collection_screen.dart';
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

  ChildProfileStore get _child => ChildProfileStore.instance;

  // 18px side padding, matching the pregnancy home (fromLTRB(18,…,18,…)). The
  // parenting home used 24, which made its cards visibly narrower side by side.
  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: c);
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
              final leap = currentLeap(_child);
              return ListView(
                padding: EdgeInsets.only(top: 12, bottom: widget.home ? 100 : 40),
                children: [
                  // The old top row was a lone hamburger + a "My Child" label —
                  // a whole row spent on nothing. It is now a proper brand
                  // header: ParentVeda mark + wordmark + search / profile /
                  // Explore icons, exactly like the pregnancy home.
                  _pad(_brandHeader()),
                  const SizedBox(height: 16),
                  // The "How <name> is today" heading now lives INSIDE the hero
                  // as a greeting line (like the pregnancy hero's "Good morning"
                  // sits inside its card), saving the whole page-level lead that
                  // used to sit above. The video still keeps its own lead below.
                  _leapHero(leap),
                  const SizedBox(height: 26),
                  // Video sits right under the hero. It carries its own header
                  // inside the card now (like the pregnancy "Today's Video"),
                  // so it no longer needs a page-level lead above it.
                  if (leap.videoId != null) ...[
                    _leapVideo(leap),
                    const SizedBox(height: 26),
                  ],
                  // Today's Parenting Tip — the pregnancy home's GrowModule
                  // card, replicated: its "TODAY'S PARENTING TIP" eyebrow lives
                  // inside the card (like the pregnancy one), so there is no
                  // separate page lead above it.
                  _dailyTip(),
                  const SizedBox(height: 26),
                  _leapDescription(leap),
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
                  _leapWatch(leap),
                  const SizedBox(height: 26),
                  _leapLearn(leap),
                  const SizedBox(height: 26),
                  _lookingAhead(),
                  const SizedBox(height: 26),
                  // The two timelines the early My Child page carried (before it
                  // became the home): the Memory timeline (journal) and the
                  // Health timeline. Restored here, at the bottom of the home.
                  _timelines(),
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
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: ppPurple, letterSpacing: -0.5)),
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
  Widget _leapHero(Leap leap) {
    final a = leap.accent;
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
        // Greeting line — the old page-level "How <name> is today" heading,
        // folded in here to save space (the pregnancy hero greets the same way).
        Row(children: [
          const Icon(Icons.wb_sunny_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 7),
          Expanded(
            child: Text('How ${_child.name} is today',
                style: ppBody(11.5, color: Colors.white.withValues(alpha: 0.88), w: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 13),
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
              Text('${leap.label} · ${leap.name}',
                  style: ppBody(12, color: Colors.white.withValues(alpha: 0.9), w: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          // The leap page is now reached by this quieter chip rather than the
          // whole card being one tap target (the card holds interactive growth
          // controls now, so a card-wide tap would fight them).
          GestureDetector(
            onTap: () => _push(LeapDefinitionScreen(leap: leap)),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('The leap', style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
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
        _leapJourney(leap),

        // ---- growth, folded into the hero ------------------------------------
        const SizedBox(height: 15),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
        const SizedBox(height: 13),
        Row(children: [
          Text('GROWTH', style: ppBody(9, color: w70, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
          const Spacer(),
          _heroAction(Icons.edit_outlined, 'Edit', _openGrowthEdit),
          const SizedBox(width: 14),
          _heroAction(Icons.show_chart_rounded, 'Chart', () => _push(const GrowthJourneyScreen())),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _heroStat('Weight', _child.weightKg.toStringAsFixed(1), 'kg', '~${e.weightKg.toStringAsFixed(1)}')),
          Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.18)),
          Expanded(child: _heroStat('Height', _child.heightCm.toStringAsFixed(0), 'cm', '~${e.heightCm.toStringAsFixed(0)}')),
          Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.18)),
          Expanded(child: _heroStat('Head', _child.headCm.toStringAsFixed(0), 'cm', '~${e.headCm.toStringAsFixed(0)}')),
        ]),
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
          Text('LEAP JOURNEY', style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
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
            child: Text(status, style: ppBody(12, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
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
          Text('LEAP JOURNEY', style: ppBody(9, color: w70, w: FontWeight.w800).copyWith(letterSpacing: 1.0)),
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
              style: ppBody(8.5, color: Colors.white.withValues(alpha: 0.7), w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
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
          Text('exp $expected', style: ppBody(9.5, color: Colors.white.withValues(alpha: 0.65)), maxLines: 1, overflow: TextOverflow.ellipsis),
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
            Text('LIVE NOW', style: ppBody(9.5, color: Colors.white.withValues(alpha: 0.9), w: FontWeight.w700).copyWith(letterSpacing: 1.0)),
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
          Expanded(child: _growthStat('Weight', _child.weightKg.toStringAsFixed(1), 'kg', '~${e.weightKg.toStringAsFixed(1)}')),
          _statDivider(),
          Expanded(child: _growthStat('Height', _child.heightCm.toStringAsFixed(0), 'cm', '~${e.heightCm.toStringAsFixed(0)}')),
          _statDivider(),
          Expanded(child: _growthStat('Head', _child.headCm.toStringAsFixed(0), 'cm', '~${e.headCm.toStringAsFixed(0)}')),
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
              style: ppBody(8.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: ppJakarta(18)),
              TextSpan(text: ' $unit', style: ppBody(10.5, color: ppSoft, w: FontWeight.w600)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text('exp $expected', style: ppBody(9.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );

  // The old three-tile growth block. Kept for revert.
  // ignore: unused_element
  Widget _growthOld() {
    final e = _child.expected;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(Row(children: [
        Expanded(child: Text('Growth', style: ppJakarta(17))),
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
        Expanded(child: _growthCard('Weight', _child.weightKg.toStringAsFixed(1), 'kg', '~${e.weightKg.toStringAsFixed(1)} kg')),
        const SizedBox(width: 12),
        Expanded(child: _growthCard('Height', _child.heightCm.toStringAsFixed(0), 'cm', '~${e.heightCm.toStringAsFixed(0)} cm')),
        const SizedBox(width: 12),
        Expanded(child: _growthCard('Head', _child.headCm.toStringAsFixed(0), 'cm', '~${e.headCm.toStringAsFixed(0)} cm')),
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
          Text(label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
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
  //  Daily tip
  // =========================================================================
  //  Tinted rather than white, the way the pregnancy HomeCard marks a
  //  highlighted module — same card shell, one accent wash.
  //  Today's Parenting Tip — a faithful copy of the pregnancy home's GrowModule
  //  card (a HomeCard): the "TODAY'S PARENTING TIP" eyebrow with the leaf icon,
  //  the tip title in quotes, the body as the one-line hook, and a full-width
  //  "Read more" button. It must read, unmistakably, as *today's tip*.
  //  Content unchanged: still whatever dailyTip() returns.
  Widget _dailyTip() {
    final t = dailyTip();
    return _pad(ppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.eco_rounded, size: 16, color: ppPurple),
          const SizedBox(width: 7),
          Expanded(
            child: Text('TODAY\'S PARENTING TIP',
                style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: ppPurple)),
          ),
        ]),
        const SizedBox(height: 10),
        Text('“${t.title}”', style: ppJakarta(20)),
        const SizedBox(height: 12),
        Text(t.body, style: ppBody(15, color: ppInk, h: 1.55, w: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ppPurple,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _openTipSheet(t),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Read more', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
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
  //  and a Watch button. No content change — same leap video, duration, expert.
  Widget _leapVideo(Leap leap) {
    final v = watchVideoById(leap.videoId!);
    final a = leap.accent;
    final cat = leap.watchCategory ?? 'Brain Development';
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
            Expanded(child: Text('The leap, in a video', style: ppJakarta(16))),
            GestureDetector(
              onTap: () => _push(WatchCategoryScreen(category: cat)),
              behavior: HitTestBehavior.opaque,
              child: Text('More videos', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
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
              Text(v.title, style: ppJakarta(15.5)),
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
  Widget _leapDescription(Leap leap) => _pad(ppSectionCard(
        eyebrow: 'The leap explained',
        icon: Icons.auto_awesome_outlined,
        title: 'What Leap ${leap.number} means',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(leap.summary, style: ppBody(14.5, color: ppInk, h: 1.65)),
          if (_leapExpanded)
            for (final s in leap.sections) ...[
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
      (Icons.restaurant_outlined, 'Nutrition', 'Milk is everything', 'Solids open up around 6 months, a few weeks away yet.', 'On track', () => _push(const RecipesScreen())),
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
                  Text(domain.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 2),
                  Text(stage, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const SizedBox(width: 10),
              _statusPill(status),
            ]),
            const SizedBox(height: 9),
            Text(insight, style: ppBody(12.5, h: 1.5)),
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
  Widget _milestones() {
    final areas = ['gross_motor', 'cognitive', 'language', 'emotional'].map(devAreaById).toList();
    final rows = <(DevArea, DevStage)>[];
    for (final area in areas) {
      for (final s in activeStages(area)) {
        rows.add((area, s));
      }
    }
    return _pad(ppSectionCard(
      eyebrow: 'Milestones',
      icon: Icons.flag_outlined,
      accent: ppCoral,
      title: "What ${_child.name} is working on",
      child: Column(children: [
        for (final r in rows) ...[
          if (r != rows.first) ppRowDivider(),
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
                Flexible(child: Text(s.name, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Text(now ? 'NOW' : 'NEXT', style: ppBody(9, color: now ? ppCoral : const Color(0xFFC98A2B), w: FontWeight.w800).copyWith(letterSpacing: 0.5)),
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
              Expanded(child: Text("View ${_child.name}'s Storybook", style: ppBody(14, color: ppInk, w: FontWeight.w600))),
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
  Widget _leapWatch(Leap leap) {
    final cat = leap.watchCategory ?? 'Brain Development';
    final videos = watchByCategory(cat);
    if (videos.isEmpty) return const SizedBox.shrink();
    // The pregnancy home's product-carousel shape: a gradient header band +
    // a compact rail, which packs the same content into much less height than
    // the loose eyebrow + title + rail the parenting side had.
    return _pad(ppCarousel(
      accent: leap.accent,
      icon: Icons.play_circle_outline_rounded,
      title: 'Videos for this leap',
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
                Container(height: 84, decoration: BoxDecoration(color: leap.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(Icons.play_circle_outline, size: 28, color: leap.accent))),
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
  Widget _leapLearn(Leap leap) {
    final colId = leap.readCollection ?? 'brain';
    final reads = articlesInCollection(colId);
    if (reads.isEmpty) return const SizedBox.shrink();
    return _pad(ppCarousel(
      accent: ppPurple,
      icon: Icons.menu_book_outlined,
      title: 'Reads for this leap',
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
    final next = nextLeap(_child);
    if (next == null) return const SizedBox.shrink();
    return _pad(GestureDetector(
      onTap: () => _push(LeapDefinitionScreen(leap: next)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Row(children: [
          Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: next.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.brightness_4_rounded, size: 19, color: next.accent)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LOOKING AHEAD', style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
              const SizedBox(height: 3),
              Text('${next.label} · ${next.name}', style: ppBody(13.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
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
  // =========================================================================
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
                Text(title, style: ppJakarta(14.5)),
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

  // ---- growth / profile edit sheet ----------------------------------------
  Future<void> _openGrowthEdit() async {
    final nameCtl = TextEditingController(text: _child.name);
    final wCtl = TextEditingController(text: _child.weightKg.toStringAsFixed(1));
    final hCtl = TextEditingController(text: _child.heightCm.toStringAsFixed(0));
    final headCtl = TextEditingController(text: _child.headCm.toStringAsFixed(0));
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
                Text('Edit profile & growth', style: ppJakarta(18)),
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
                      Text('${dob.day} ${_monthsShort[dob.month - 1]} ${dob.year}', style: ppBody(13.5, color: ppSoft)),
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
