// =============================================================================
//  Parenting · the Tools tab, in the one ParentVeda format (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "for parenting the tools section is also very inconsistent ...
//  have the reference of pregnancy and trying to conceive". So this is the
//  pregnancy Tools tab (`lib/screens/tools_hub_screen.dart`), which is TTC's:
//  TtcTabRootHeader with the live search under it, groups headed by the violet
//  caps eyebrow, PvRowGroup of PvListRow, and the TTC family's drawn marks
//  (`ttcFamilyMarkForIntent`) as every row's leading. The old screen is
//  `ToolsHubClassic` in tools_hub_screen.dart, kept for revert.
//
//  Every tool the parenting stage has is here, once, opened through the one
//  surface router (`ppScreenForSurface`), so a tool reached from a door and
//  from this tab is the same screen.
//
//  Mobbin: a tracker row carries its latest entry ("Last feed 2h ago"), after
//  Withings Health Mate (mobbin.com/screens/72f11245-eb96-405a-be2a-91b05ce7b01c)
//  and Apple Health's All Health Data
//  (mobbin.com/screens/c4a99041-293c-49bc-8a64-8c9a9fbbd802).
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../doors/pv_live_search.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import '../ttc/ttc_tab_root_header.dart' show TtcTabRootHeader, ttcTabRootIntroStyle;
import '../ttc/ttc_tool_marks.dart' show ttcFamilyMarkForIntent;
import '../v2/v2_palette.dart';
import 'pp_care_log_data.dart';
import 'pp_care_parts.dart' show ppCareAgo;
import 'pp_child_profile.dart';
import 'pp_common.dart' show PpBottomNav, PpTab;
import 'pp_feeding_data.dart';
import 'pp_growth_data.dart';
import 'pp_search.dart' show openPpAskVeda;
import 'pp_sleep_data.dart';
import 'pp_surface_router.dart' show ppScreenForSurface;
import 'pp_vaccine_data.dart';

class PpTool {
  const PpTool(this.title, this.line, this.surfaceId, this.mark, {this.live, this.words = const []});
  final String title;
  final String line;
  final String surfaceId;
  final IntentMark mark;

  /// The latest entry, when the tool logs something (Withings' pattern).
  final String? Function()? live;

  /// Other words she may type for it.
  final List<String> words;
}

class PpToolGroup {
  const PpToolGroup(this.title, this.hue, this.tools);
  final String title;
  final double hue;
  final List<PpTool> tools;
}

String? _lastFeed() {
  final f = FeedingStore.instance.last;
  return f == null ? null : 'Last feed ${ppCareAgo(f.time)}';
}

String? _lastSleep() {
  final s = SleepStore.instance.last;
  return s == null ? null : 'Woke ${ppCareAgo(s.end)}';
}

String? _nappies() {
  final n = NappyStore.instance.wetToday;
  return NappyStore.instance.last == null ? null : '$n wet today';
}

String? _lastPump() {
  final p = PumpStore.instance.last;
  return p == null ? null : 'Last pumped ${ppCareAgo(p.time)}';
}

String? _growth() {
  final g = GrowthStore.instance.latest;
  return g == null ? null : '${g.weightKg.toStringAsFixed(1)} kg, ${ppCareAgo(g.date)}';
}

/// The groups, in the order a parent of a young baby reaches for them.
List<PpToolGroup> ppToolGroups() {
  final under1 = ChildProfileStore.instance.ageInMonths < 12;
  return [
    PpToolGroup('Log the day', 206, [
      PpTool('Feeding', 'Breast, bottle or solids, in one tap.', 'pp_feeding', IntentMark.forkMark,
          live: _lastFeed, words: ['feed', 'milk', 'bottle', 'breast', 'doodh']),
      PpTool('Sleep', 'Naps and nights, and the wake window.', 'pp_sleep', IntentMark.sunMark,
          live: _lastSleep, words: ['nap', 'night', 'neend']),
      PpTool('Nappies', 'Wet and dirty, the clearest sign milk is going in.', 'pp_nappies', IntentMark.checkMark,
          live: _nappies, words: ['diaper', 'poo', 'wee']),
      if (under1)
        PpTool('Breastfeed timer', 'Time each side, and see which side is next.', 'pp_feed_timer',
            IntentMark.timelineRail, words: ['side', 'latch']),
      PpTool('Pumping', 'How much, from which side, and when.', 'pp_pump', IntentMark.listMark,
          live: _lastPump, words: ['express', 'pump']),
      if (under1)
        PpTool('Tummy time', 'A few minutes, a few times a day.', 'pp_tummy_time', IntentMark.bodyMark),
      PpTool('The last 7 days', 'Feeds, sleep and nappies, to share with your doctor.', 'pp_care_history',
          IntentMark.chartLog, words: ['history', 'report', 'week']),
    ]),
    PpToolGroup('Growth and health', 152, [
      PpTool('Growth', 'Weight, height and head size on the WHO curves.', 'pp_growth', IntentMark.scaleMark,
          live: _growth, words: ['weight', 'height', 'percentile']),
      PpTool('Vaccines', 'What is done, what is next, and the day it was given.', 'pp_vaccines',
          IntentMark.pillMark, live: () => VaxStore.instance.nextVisitSubtitle, words: ['shots', 'tika', 'vaccination']),
      PpTool('Is my baby OK?', 'A symptom, checked calmly, and when to call.', 'pp_baby_ok_check',
          IntentMark.questionMark, words: ['fever', 'sick', 'symptom']),
      PpTool('Health record', 'Visits, illnesses and papers in one place.', 'pp_health_home', IntentMark.reportPage,
          words: ['records', 'documents']),
      PpTool('Emergency card', 'Blood group, allergies and two numbers to call.', 'pp_emergency_card',
          IntentMark.askDoctor, words: ['emergency', 'sos']),
    ]),
    PpToolGroup('Growing and learning', 28, [
      PpTool("This month's checklist", 'What usually comes next, and what to try.', 'pp_month_checklist',
          IntentMark.calendarDay, words: ['month']),
      PpTool('Milestones', 'Where your baby is right now, without a score.', 'pp_milestones', IntentMark.stepsMark,
          words: ['development', 'rolling', 'walking']),
      PpTool('A gentle check-in', 'A few questions, and when to ask your paediatrician.', 'pp_dev_checkin',
          IntentMark.lampMark, words: ['delay', 'worry']),
      PpTool('Something changed?', 'Sleep, feeding or mood suddenly different.', 'pp_what_changed',
          IntentMark.nextStep, words: ['regression', 'leap', 'fussy']),
    ]),
    PpToolGroup('Food', 96, [
      PpTool('Can my baby eat this?', '289 foods, by age, with the reason.', 'pp_baby_food_check',
          IntentMark.forkMark, words: ['food', 'honey', 'egg', 'solids']),
      PpTool('Recipes', 'Indian home cooking for each age.', 'pp_food', IntentMark.cookMark,
          words: ['recipe', 'khichdi', 'meal']),
    ]),
    PpToolGroup('For you', 288, [
      PpTool('Can I...?', 'Quick answers while you breastfeed.', 'pp_maa_can_i', IntentMark.lotusMark,
          words: ['medicine', 'chai', 'fasting']),
      PpTool('How have you been?', 'Two questions. No score, nothing saved.', 'pp_mood_check',
          IntentMark.cuppedHands, words: ['mood', 'sad', 'low', 'anxious']),
    ]),
    PpToolGroup('Plan and keep', 268, [
      PpTool('Baby names', '2,031 names, with meaning, origin and Devanagari.', 'pp_names', IntentMark.pageMark,
          words: ['name']),
      PpTool('Product guide', 'What is worth buying, and what to skip.', 'pp_product_guide', IntentMark.bagMark,
          words: ['buy', 'products']),
    ]),
  ];
}

class ToolsHubScreen extends StatefulWidget {
  const ToolsHubScreen({super.key});

  @override
  State<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends State<ToolsHubScreen> {
  final PvLiveSearch _search = PvLiveSearch();
  static const double _g = 18;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(PpTool t) {
    final screen = ppScreenForSurface(t.surfaceId);
    if (screen == null) return;
    pvCommitFeedback();
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: t.surfaceId),
      builder: (_) => screen,
    ));
  }

  bool _matches(PpTool t, String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return false;
    return t.title.toLowerCase().contains(s) ||
        t.line.toLowerCase().contains(s) ||
        t.words.any((w) => w.contains(s) || s.contains(w));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _search,
        FeedingStore.instance,
        SleepStore.instance,
        NappyStore.instance,
        PumpStore.instance,
        GrowthStore.instance,
        VaxStore.instance,
        ChildProfileStore.instance,
      ]),
      builder: (context, _) {
        final p = pvStorePalette;
        final groups = ppToolGroups();
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            PvLiveSearchScope(
              search: _search,
              child: ListView(
                key: const ValueKey('pp_tools_tab'),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, kAskFabReserve + 90),
                children: [
                  TtcTabRootHeader(
                    title: 'Tools',
                    intro: PvLiveSearchWords(
                      search: _search,
                      child: Text(
                          'Tools to log the day, keep track of growth and health, and plan ahead. '
                          'Tap one to open it. None of them are required.',
                          style: ttcTabRootIntroStyle()),
                    ),
                    below: PvLiveSearchField(search: _search, p: p, hint: 'Find a tool'),
                  ),
                  if (_search.searching)
                    ..._results(p, groups)
                  else
                    for (final g in groups) ..._group(p, g),
                ],
              ),
            ),
            const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: PpTab.tools)),
          ]),
        );
      },
    );
  }

  Widget _pad(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: _g), child: child);

  List<Widget> _group(V2Palette p, PpToolGroup g) => [
        const SizedBox(height: 28),
        _pad(Text(g.title.toUpperCase(),
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action))),
        const SizedBox(height: 6),
        _pad(PvRowGroup(p: p, children: [for (final t in g.tools) _row(p, t, g.hue)])),
      ];

  Widget _row(V2Palette p, PpTool t, double hue) {
    final live = t.live?.call();
    return PvListRow(
      key: ValueKey('pp_tool_${t.surfaceId}'),
      p: p,
      leading: ttcFamilyMarkForIntent(t.mark, v2BlockTint(hue % 360, p)) ??
          PvMarkWell(p: p, hue: hue, size: 40, mark: t.mark),
      title: t.title,
      line: live ?? t.line,
      onTap: () => _open(t),
    );
  }

  List<Widget> _results(V2Palette p, List<PpToolGroup> groups) {
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
        _pad(PvRowGroup(p: p, children: [for (final (t, hue) in hits) _row(p, t, hue)])),
      const SizedBox(height: 14),
      _pad(PvLiveSearchWayOn(
        p: p,
        icon: Icons.auto_awesome_outlined,
        title: 'Ask Veda about "$q"',
        line: 'In your own words, with your child\'s age in mind.',
        onTap: () {
          _search.focus.unfocus();
          openPpAskVeda(context, q);
        },
      )),
    ];
  }
}
