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

import 'development_area_screen.dart';
import 'dev_stage_detail_screen.dart';
import 'explore_drawer.dart';
import 'recipes_screen.dart';
// Old light growth screen retired in favour of the new Growth Journey tool
// (kept for revert). import 'health_growth_screen.dart';
import 'growth_journey_screen.dart';
import 'journal_v2/journal_capture_screens.dart';
import 'journal_v2/journal_storybook_screens.dart';
import 'leap_definition_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_daily_tips.dart';
import 'pp_development_data.dart';
import 'pp_leaps_data.dart';
import 'pp_reading_data.dart';
import 'pp_watch_data.dart';
import 'reading_collection_screen.dart';
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

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ppBg,
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
                  _pad(_topBar()),
                  const SizedBox(height: 14),
                  _leapHeader(leap),
                  const SizedBox(height: 20),
                  _identity(leap),
                  const SizedBox(height: 22),
                  _growth(),
                  const SizedBox(height: 30),
                  _dailyTip(),
                  const SizedBox(height: 30),
                  if (leap.videoId != null) ...[_leapVideo(leap), const SizedBox(height: 24)],
                  _leapDescription(leap),
                  const SizedBox(height: 34),
                  _snapshot(),
                  const SizedBox(height: 34),
                  _milestones(),
                  const SizedBox(height: 34),
                  _journal(),
                  const SizedBox(height: 34),
                  _leapWatch(leap),
                  const SizedBox(height: 30),
                  _leapLearn(leap),
                  const SizedBox(height: 30),
                  _lookingAhead(),
                ],
              );
            },
          ),
          if (widget.home) const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 0)),
        ]),
      ),
    );
  }

  // ---- top bar (hamburger on home, back when pushed) ----------------------
  Widget _topBar() {
    if (widget.home) {
      return Row(children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: ppHair), boxShadow: ppCardShadow),
            child: const Icon(Icons.menu_rounded, size: 22, color: ppInk),
          ),
        ),
        const Spacer(),
        ppEyebrow('My Child', color: ppMuted, spacing: 1.2),
      ]);
    }
    return ppBack(context, 'My Child');
  }

  // =========================================================================
  //  Leap header (the header, like the leap page)
  // =========================================================================
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
  // =========================================================================
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
  Widget _growth() {
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
  Widget _dailyTip() {
    final t = dailyTip();
    return _pad(Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 16, color: ppPurple),
          const SizedBox(width: 8),
          Flexible(child: ppEyebrow("Today's tip · ${t.title}", color: ppPurple, spacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        Text(t.body, style: ppBody(14, color: ppInk, h: 1.6)),
      ]),
    ));
  }

  // =========================================================================
  //  Leap video
  // =========================================================================
  Widget _leapVideo(Leap leap) {
    final v = watchVideoById(leap.videoId!);
    final a = leap.accent;
    return _pad(GestureDetector(
      onTap: () => _push(v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair), boxShadow: ppCardShadow),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 168,
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a.withValues(alpha: 0.85), Color.lerp(a, Colors.black, 0.3)!])),
            alignment: Alignment.center,
            child: Container(width: 56, height: 56, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle), child: Icon(Icons.play_arrow_rounded, size: 30, color: a)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('The leap, in a video', color: ppPurple, spacing: 1.0),
              const SizedBox(height: 8),
              Text(v.title, style: ppJakarta(19)),
              const SizedBox(height: 6),
              Text('${v.durationLabel} · ${v.expert.name}', style: ppBody(12.5, color: ppMuted)),
            ]),
          ),
        ]),
      ),
    ));
  }

  // =========================================================================
  //  Leap description (expandable)
  // =========================================================================
  Widget _leapDescription(Leap leap) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(Text('What Leap ${leap.number} means', style: ppJakarta(18))),
        const SizedBox(height: 10),
        _pad(Text(leap.summary, style: ppBody(14.5, color: ppInk, h: 1.65))),
        if (_leapExpanded) ...[
          for (final s in leap.sections) ...[
            const SizedBox(height: 18),
            _pad(Text(s.heading, style: ppJakarta(15.5))),
            const SizedBox(height: 8),
            for (final p in s.paragraphs) ...[
              _pad(Text(p, style: ppBody(14, color: ppInk, h: 1.6))),
              const SizedBox(height: 10),
            ],
          ],
        ],
        const SizedBox(height: 14),
        _pad(GestureDetector(
          onTap: () => setState(() => _leapExpanded = !_leapExpanded),
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Flexible(child: Text(_leapExpanded ? 'Show less' : 'Read the full description', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 5),
            Icon(_leapExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 19, color: ppPurple),
          ]),
        )),
      ]);

  // =========================================================================
  //  Child snapshot (five domains - unchanged layout)
  // =========================================================================
  Widget _snapshot() {
    final cards = <(IconData, String, String, String, String, VoidCallback)>[
      (Icons.psychology_outlined, 'Brain', 'Cause & effect', 'Following your hand all the way to the toy it reaches for.', 'Developing', () => _push(DevelopmentAreaScreen(area: devAreaById('cognitive')))),
      (Icons.child_care_outlined, 'Physical', 'Rolling & reaching', 'Hands clasp at his chest, he pushes up - a first roll any day.', 'Emerging', () => _push(DevelopmentAreaScreen(area: devAreaById('gross_motor')))),
      (Icons.chat_bubble_outline_rounded, 'Language', 'Musical babble', "Coos stretching into 'aah-goo', raspberries and squeals.", 'Emerging', () => _push(DevelopmentAreaScreen(area: devAreaById('language')))),
      (Icons.favorite_border, 'Emotional', 'Social joy', 'Beams at you across a room; a laugh now earns a laugh back.', 'Blossoming', () => _push(DevelopmentAreaScreen(area: devAreaById('emotional')))),
      (Icons.restaurant_outlined, 'Nutrition', 'Milk is everything', 'Solids open up around 6 months - a few weeks away yet.', 'On track', () => _push(const RecipesScreen())),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(_header('Child snapshot', 'How ${_child.name} is doing', sub: 'Five windows into his development - where he is right now, not a scorecard. Tap any to go deeper.')),
      const SizedBox(height: 18),
      _pad(Column(children: [
        for (final c in cards) ...[
          _snapCard(c.$1, c.$2, c.$3, c.$4, c.$5, c.$6),
          if (c != cards.last) const SizedBox(height: 12),
        ],
      ])),
    ]);
  }

  Widget _snapCard(IconData icon, String domain, String stage, String insight, String status, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair), boxShadow: const [BoxShadow(color: Color(0x0F6A30B6), blurRadius: 18, spreadRadius: -14, offset: Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 19, color: ppPurple)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(domain.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 2),
                  Text(stage, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const SizedBox(width: 10),
              _statusPill(status),
            ]),
            const SizedBox(height: 12),
            Text(insight, style: ppBody(13, h: 1.5)),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(_header('Milestones', "What he's working on now", sub: 'The milestones just under way and just ahead. Tap any to read what it is and how to help.')),
      const SizedBox(height: 18),
      _pad(Column(children: [
        for (final r in rows) _milestoneRow(r.$1, r.$2),
      ])),
    ]);
  }

  Widget _milestoneRow(DevArea area, DevStage s) {
    final now = s.status == 'current';
    final a = area.accent;
    return GestureDetector(
      onTap: () => _push(DevStageDetailScreen(area: area, stage: s, kindLabel: 'Milestone')),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(_header('Journal', 'Moments worth keeping', sub: 'Capture today, in whatever way suits the moment.')),
      const SizedBox(height: 18),
      _pad(Row(children: [
        for (int i = 0; i < 2; i++) ...[
          Expanded(child: _journalTile(tiles[i].$1, tiles[i].$2, tiles[i].$3)),
          if (i == 0) const SizedBox(width: 12),
        ],
      ])),
      const SizedBox(height: 12),
      _pad(Row(children: [
        for (int i = 2; i < 4; i++) ...[
          Expanded(child: _journalTile(tiles[i].$1, tiles[i].$2, tiles[i].$3)),
          if (i == 2) const SizedBox(width: 12),
        ],
      ])),
      const SizedBox(height: 14),
      _pad(GestureDetector(
        onTap: () => _push(const StorybookReaderScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.auto_stories_outlined, size: 19, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(child: Text("View ${_child.name}'s Storybook", style: ppBody(14, color: ppInk, w: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      )),
    ]);
  }

  Widget _journalTile(IconData icon, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 19, color: ppPurple)),
            const SizedBox(height: 12),
            Text(label, style: ppBody(13.5, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: _header('Watch', 'Videos for this leap')),
        GestureDetector(onTap: () => _push(WatchCategoryScreen(category: cat)), behavior: HitTestBehavior.opaque, child: ppSeeAll('View more')),
      ])),
      const SizedBox(height: 16),
      SizedBox(
        height: 178,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: videos.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final v = videos[i];
            return GestureDetector(
              onTap: () => _push(v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v)),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 180,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 100, decoration: BoxDecoration(color: leap.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Center(child: Icon(Icons.play_circle_outline, size: 30, color: leap.accent))),
                  const SizedBox(height: 9),
                  Text(v.title, style: ppJakarta(13.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${v.durationLabel} · ${v.expert.name}', style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // =========================================================================
  //  Leap-related Learn rail
  // =========================================================================
  Widget _leapLearn(Leap leap) {
    final colId = leap.readCollection ?? 'brain';
    final reads = articlesInCollection(colId);
    if (reads.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: _header('READ', 'Reads for this leap')),
        GestureDetector(onTap: () => _push(ReadingCollectionScreen(collection: readCollectionById(colId))), behavior: HitTestBehavior.opaque, child: ppSeeAll('View more')),
      ])),
      const SizedBox(height: 16),
      SizedBox(
        height: 178,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: reads.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final a = reads[i];
            return GestureDetector(
              onTap: () => _push(ReadingReaderScreen(article: a)),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 180,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 100, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)), child: const Center(child: Icon(Icons.menu_book_outlined, size: 28, color: ppPurple))),
                  const SizedBox(height: 9),
                  Text(a.title, style: ppJakarta(13.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${a.minutes} min · ${a.author}', style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
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

  // ---- section header -----------------------------------------------------
  Widget _header(String eyebrow, String title, {String? sub}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow(eyebrow, color: ppPurple, spacing: 1.2),
        const SizedBox(height: 8),
        Text(title, style: ppJakarta(24)),
        if (sub != null) ...[
          const SizedBox(height: 8),
          Text(sub, style: ppBody(13.5, h: 1.55)),
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
