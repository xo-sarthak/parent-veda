// =============================================================================
//  Parenting · the Brain activities tab, in the one ParentVeda format
// -----------------------------------------------------------------------------
//  2026-10-07. The user: "The brain activities section in the bottom
//  navigation menu ... is of the old UI, which we don't want ... version two
//  and version 3 are the ones that should be looked upon".
//
//  V3's STRUCTURE, kept (grow_v3_screens.dart explains each choice): one thing
//  worth doing today; a week that fills, never a streak that breaks; the six
//  capabilities a parent would name ("Move", "Talk"), not a textbook's
//  domains; the map and the check-in one tap down, never gone.
//
//  THE NEW LANGUAGE, drawn: the tab-root header and live search every other
//  tab has (TtcTabRootHeader); the capabilities as the store's chips over a
//  rail of the doors' shelf cards, after Fitbit's category page
//  (mobbin.com/screens/c84f0ef8-f13d-48db-9e91-d3fb8bb65f64) and Tiimo's
//  explore list with a time on every card
//  (mobbin.com/screens/1d3005b1-93c6-404e-9197-23decbe9f0ea); the wider view as
//  PvListRow. The bottom bar is drawn here (it was missing on this tab), and
//  the review-only V1/V2/V3 pill is gone. GrowHomeScreen is kept for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../widgets/pv_feedback.dart';
import '../doors/pv_list_row.dart';
import '../doors/pv_live_search.dart';
import '../doors/pv_shelf_card.dart';
import '../doors/pv_shelf_spec.dart' show PvShelfKind;
import '../products/pv_store_chrome.dart' show PvChip, PvCommit, PvSecondary, pvStorePalette;
import '../ttc/ttc_tab_root_header.dart' show TtcTabRootHeader, ttcTabRootIntroStyle;
import '../v2/v2_palette.dart';
import 'development_checkin_screen.dart';
import 'development_map_screen.dart';
import 'grow_v2_screens.dart' show GrowActivityScreen;
import 'milestone_journey_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart' show PpBottomNav, PpTab;
import 'pp_development_data.dart' show DevActivity;
import 'pp_grow_data.dart';

class PpBrainTabScreen extends StatefulWidget {
  const PpBrainTabScreen({super.key});

  @override
  State<PpBrainTabScreen> createState() => _PpBrainTabScreenState();
}

class _PpBrainTabScreenState extends State<PpBrainTabScreen> {
  final PvLiveSearch _search = PvLiveSearch();
  String _cap = kGrowCapabilities.first.id;
  static const double _g = 18;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _push(Widget s, String route) {
    pvCommitFeedback();
    Navigator.of(context).push(MaterialPageRoute<void>(settings: RouteSettings(name: route), builder: (_) => s));
  }

  void _openActivity(DevActivity a) => _push(GrowActivityScreen(activity: a), 'pp/brain/${a.id}');

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: _g), child: c);

  Widget _head(V2Palette p, String t) => _pad(Text(t,
      style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([GrowStore.instance, ChildProfileStore.instance, _search]),
      builder: (context, _) {
        final p = pvStorePalette;
        final child = ChildProfileStore.instance;
        final months = child.devAgeInMonths;
        final today = growToday(ageMonths: months);
        final forAge = growActivitiesForAge(months);
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            PvLiveSearchScope(
              search: _search,
              child: ListView(
                key: const ValueKey('pp_brain_tab'),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, kAskFabReserve + 90),
                children: [
                  TtcTabRootHeader(
                    title: 'Brain activities',
                    intro: PvLiveSearchWords(
                      search: _search,
                      child: Text(
                          'One thing worth doing with ${child.nameMid} today, and every activity for the age. '
                          'A few minutes of play is the whole point.',
                          style: ttcTabRootIntroStyle()),
                    ),
                    below: PvLiveSearchField(search: _search, p: p, hint: 'Find an activity'),
                  ),
                  if (_search.searching)
                    ..._results(p, forAge)
                  else ...[
                    const SizedBox(height: 24),
                    _head(p, 'One thing, today'),
                    const SizedBox(height: 12),
                    _pad(_today(p, today)),
                    const SizedBox(height: 16),
                    _pad(_week(p)),
                    const SizedBox(height: 30),
                    _head(p, 'What you are building'),
                    const SizedBox(height: 6),
                    _pad(Text(_capability(_cap).promise,
                        style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2))),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: _g),
                      child: Row(children: [
                        for (final c in kGrowCapabilities) ...[
                          KeyedSubtree(
                            key: ValueKey('pp_brain_cap_${c.id}'),
                            child: PvChip(label: c.label, selected: c.id == _cap, onTap: () => setState(() => _cap = c.id)),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 14),
                    _rail(p, [for (final a in forAge) if (capabilitiesOf(a).any((c) => c.id == _cap)) a]),
                    const SizedBox(height: 30),
                    _head(p, 'The wider view'),
                    const SizedBox(height: 8),
                    _pad(PvRowGroup(p: p, children: [
                      PvListRow(
                        p: p,
                        leading: PvMarkWell(p: p, hue: 206, size: 40, icon: Icons.map_outlined),
                        title: 'The development map',
                        line: 'Birth to five, and where ${child.they} is on it.',
                        onTap: () => _push(const DevelopmentMapScreen(), 'pp/brain/map'),
                      ),
                      PvListRow(
                        p: p,
                        leading: PvMarkWell(p: p, hue: 28, size: 40, icon: Icons.flag_outlined),
                        title: 'Milestones',
                        line: 'What is emerging now, without a score.',
                        onTap: () => _push(const MilestoneJourneyScreen(), 'pp_milestones'),
                      ),
                      PvListRow(
                        p: p,
                        leading: PvMarkWell(p: p, hue: 160, size: 40, icon: Icons.checklist_rounded),
                        title: 'A gentle check-in',
                        line: 'A few questions, and when to ask your paediatrician.',
                        onTap: () => _push(const DevelopmentCheckinScreen(), 'pp_dev_checkin'),
                      ),
                    ])),
                    const SizedBox(height: 30),
                    _head(p, 'Already done together'),
                    const SizedBox(height: 8),
                    if (GrowStore.instance.recentlyCompleted().isEmpty)
                      _pad(Text('Nothing yet. Today\'s activity is a good place to start.',
                          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
                    else
                      _pad(PvRowGroup(p: p, children: [
                        for (final a in GrowStore.instance.recentlyCompleted()) _activityRow(p, a),
                      ])),
                  ],
                ],
              ),
            ),
            const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: PpTab.brain)),
          ]),
        );
      },
    );
  }

  GrowCapability _capability(String id) => capabilityById(id) ?? kGrowCapabilities.first;

  Widget _today(V2Palette p, DevActivity a) {
    final done = GrowStore.instance.isCompletedToday(a.id);
    return Container(
      key: const ValueKey('pp_brain_today'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${a.minutes} MIN  ·  ${[for (final c in capabilitiesOf(a)) c.label].join(', ').toUpperCase()}',
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.action)),
        const SizedBox(height: 8),
        Text(a.title, style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
        const SizedBox(height: 6),
        Text(a.benefit, style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
        const SizedBox(height: 14),
        if (done)
          PvSecondary(label: 'Done today. See it again', icon: Icons.check_rounded, onTap: () => _openActivity(a))
        else
          PvCommit(key: const ValueKey('pp_brain_start'), label: 'Start', onTap: () => _openActivity(a)),
      ]),
    );
  }

  /// Seven slots that fill. A missed day costs one; nothing is taken away.
  Widget _week(V2Palette p) {
    // The last seven days, ending today (weekPattern's order).
    final week = GrowStore.instance.weekPattern;
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final days = [for (var i = 6; i >= 0; i--) letters[now.subtract(Duration(days: i)).weekday - 1]];
    return Row(children: [
      for (var i = 0; i < week.length && i < 7; i++) ...[
        Expanded(
          child: Column(children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: week[i] ? p.ink1 : p.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(days[i], style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: p.ink3)),
          ]),
        ),
        if (i < 6) const SizedBox(width: 6),
      ],
    ]);
  }

  Widget _rail(V2Palette p, List<DevActivity> items) {
    if (items.isEmpty) {
      return _pad(Text('Nothing for this age in this group yet. Try another.',
          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)));
    }
    return SizedBox(
      height: pvShelfRailHeight(MediaQuery.textScalerOf(context)),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _g),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final a = items[i];
          return PvShelfCard(
            key: ValueKey('pp_brain_card_${a.id}'),
            p: p,
            hue: (40 + i * 30) % 360,
            kind: PvShelfKind.game,
            kindWord: 'Activity',
            fact: '${a.minutes} min',
            title: a.title,
            onTap: () => _openActivity(a),
          );
        },
      ),
    );
  }

  Widget _activityRow(V2Palette p, DevActivity a) => PvListRow(
        p: p,
        leading: PvMarkWell(p: p, hue: 40, size: 40, icon: Icons.toys_outlined),
        title: a.title,
        line: '${a.minutes} min',
        onTap: () => _openActivity(a),
      );

  List<Widget> _results(V2Palette p, List<DevActivity> forAge) {
    final q = _search.query.trim().toLowerCase();
    final hits = [
      for (final a in kGrowActivities)
        if (a.title.toLowerCase().contains(q) || a.skills.any((s) => s.toLowerCase().contains(q))) a,
    ];
    hits.sort((x, y) => (forAge.contains(y) ? 1 : 0) - (forAge.contains(x) ? 1 : 0));
    return [
      const SizedBox(height: 18),
      if (hits.isEmpty)
        _pad(Text('No activity by that name. Try a shorter word.',
            style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)))
      else
        _pad(PvRowGroup(p: p, children: [for (final a in hits.take(30)) _activityRow(p, a)])),
    ];
  }
}
