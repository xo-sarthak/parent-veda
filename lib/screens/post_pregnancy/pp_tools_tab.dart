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
//  2026-10-24 (tools pass C1): eight door tools were reachable only from
//  their doors. The user: "doors should not cover a new tool that isn't
//  listed in tools section". They are listed now, and
//  test/pp_tools_tab_test.dart fails if a door ever offers one this tab lacks.
//
//  Mobbin: a tracker row carries its latest entry ("Last feed 2h ago"), after
//  Withings Health Mate (mobbin.com/screens/72f11245-eb96-405a-be2a-91b05ce7b01c)
//  and Apple Health's All Health Data
//  (mobbin.com/screens/c4a99041-293c-49bc-8a64-8c9a9fbbd802).
// =============================================================================

import 'package:flutter/material.dart';
import '../../ask_veda/ask_veda_mark.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../doors/pv_live_search.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import '../ttc/ttc_tab_root_header.dart' show TtcTabRootHeader, ttcTabRootIntroStyle;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading, TtcToolMark, ttcFamilyMarkForIntent;
import '../v2/v2_palette.dart';
import 'pp_care_log_data.dart';
import 'pp_care_parts.dart' show ppCareAgo;
import 'pp_child_profile.dart';
import 'pp_common.dart' show PpBottomNav, PpTab;
import 'pp_feeding_data.dart';
import 'pp_growth_data.dart';
import 'pp_names_data.dart' show kBabyNames;
import 'pp_search.dart' show openPpAskVeda;
import 'pp_baby_food_check_screen.dart' show ppBabyFoodCount;
import 'pp_sleep_data.dart';
import 'pp_surface_router.dart' show ppPushSurface, ppScreenForSurface, ppSurfaceUnavailable;
import 'pp_vaccine_data.dart';

class PpTool {
  const PpTool(this.title, this.line, this.surfaceId, this.mark,
      {this.live, this.words = const [], this.tab, this.tool});
  final String title;
  final String line;
  final String surfaceId;
  final IntentMark mark;

  /// The drawn mark this row wears (one of [tab] or [tool]). ⚠️ ONE GLYPH PER
  /// TOOL (the user, 2026-10-25: "make sure the tools section the UI is
  /// consistent with marks/glyphs"). [mark] went through the shared
  /// `ttcFamilyMarkForIntent`, which doors and pregnancy also use: six of its
  /// marks have no drawing, so those rows fell back to a plain disc with an
  /// icon, and others folded onto one glyph (three bowls, three checklists,
  /// three lotuses). Each row now names its own drawn mark, chosen by eye
  /// from a rendered sheet of all of them; [mark] stays as the fallback.
  /// Owed art: a moon (Sleep wears the clock) and a nappy (Nappies wears the
  /// drops). `test/pp_tools_tab_test.dart` holds: every row drawn, none twice.
  final TtcTabMark? tab;
  final TtcToolMark? tool;

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
      PpTool('Feeding', 'Breast, bottle or solids, in one tap.', 'pp_feeding', tab: TtcTabMark.hotBottle, IntentMark.forkMark,
          live: _lastFeed, words: ['feed', 'milk', 'bottle', 'breast', 'doodh']),
      PpTool('Sleep', 'Naps and nights, and the wake window.', 'pp_sleep', tab: TtcTabMark.clock, IntentMark.sunMark,
          live: _lastSleep, words: ['nap', 'night', 'neend']),
      PpTool('Sleep Sounds', 'Sounds to help your baby settle.', 'pp_sleep_sounds', tool: TtcToolMark.bell, IntentMark.audioMark,
          words: ['white noise', 'lullaby', 'lori']),
      PpTool('Nappies', 'Wet and dirty, the clearest sign milk is going in.', 'pp_nappies', tab: TtcTabMark.cycleDrops, IntentMark.checkMark,
          live: _nappies, words: ['diaper', 'poo', 'wee']),
      if (under1)
        PpTool('Breastfeed timer', 'Time each side, and see which side is next.', 'pp_feed_timer', tool: TtcToolMark.stopwatch,
            IntentMark.timelineRail, words: ['side', 'latch']),
      PpTool('Pumping', 'How much, from which side, and when.', 'pp_pump', tab: TtcTabMark.testStrip, IntentMark.listMark,
          live: _lastPump, words: ['express', 'pump']),
      if (under1)
        PpTool('Tummy time', 'A few minutes, a few times a day.', 'pp_tummy_time', tab: TtcTabMark.bigSmallHearts, IntentMark.bodyMark),
      PpTool('The last 7 days', 'Feeds, sleep and nappies, to share with your doctor.', 'pp_care_history', tab: TtcTabMark.chartLine,
          IntentMark.chartLog, words: ['history', 'report', 'week']),
    ]),
    PpToolGroup('Growth and health', 152, [
      PpTool('Growth', 'Weight, height and head size on the WHO curves.', 'pp_growth', tool: TtcToolMark.weight, IntentMark.scaleMark,
          live: _growth, words: ['weight', 'height', 'percentile']),
      PpTool('Vaccines', 'What is done, what is next, and the day it was given.', 'pp_vaccines', tool: TtcToolMark.vaccinations,
          IntentMark.pillMark, live: () => VaxStore.instance.nextVisitSubtitle, words: ['shots', 'tika', 'vaccination']),
      PpTool('Fever check', 'A temperature, checked calmly, and when to call.', 'pp_fever_check', tool: TtcToolMark.symptoms,
          IntentMark.thermoMark, words: ['fever', 'temperature', 'bukhar']),
      // ⚠️ ONE SYMPTOM TOOL FOR EVERY AGE (tools pass H2, 2026-10-25). Was two
      // rows: this one opened a newborn feeding check, and "Something changed?"
      // (below, kept for revert) was the real checker. Kept for revert:
      // PpTool('Is my baby OK?', 'A symptom, checked calmly, and when to call.', 'pp_baby_ok_check',
      //     IntentMark.questionMark, words: ['fever', 'sick', 'symptom']),
      PpTool('Is my baby OK?', 'Sleep, feeding, illness or mood: checked calmly, and when to call.', 'pp_what_changed', tool: TtcToolMark.partnerHealth,
          IntentMark.questionMark,
          words: ['fever', 'sick', 'symptom', 'cough', 'vomit', 'rash', 'changed', 'regression', 'fussy', 'enough milk']),
      PpTool('Health record', 'Visits, illnesses and papers in one place.', 'pp_health_home', tool: TtcToolMark.records, IntentMark.reportPage,
          words: ['records', 'documents']),
      PpTool('Before you see the doctor', 'Questions and a summary to share.' /* was 'Questions and notes to take to the visit.': no notes field (tools pass) */, 'pp_doctor_visit', tab: TtcTabMark.doctorChat,
          IntentMark.listMark, words: ['doctor', 'visit', 'questions', 'appointment']),
      PpTool('Emergency card', 'Blood group, allergies and two numbers to call.', 'pp_emergency_card', tool: TtcToolMark.hospitalBag,
          IntentMark.askDoctor, words: ['emergency', 'sos']),
      PpTool('Home remedies', 'Kitchen remedies from the elders, marked honestly.', 'pp_nuskhe', tab: TtcTabMark.jarLeaf,
          IntentMark.spoonMark, words: ['nuskhe', 'gharelu', 'remedy', 'ajwain']),
    ]),
    PpToolGroup('Growing and learning', 28, [
      PpTool("This month's checklist", 'What usually comes next, and what to try.', 'pp_month_checklist', tab: TtcTabMark.checklist,
          IntentMark.calendarDay, words: ['month']),
      PpTool('Milestones', 'Where your baby is right now, without a score.', 'pp_milestones', tab: TtcTabMark.flagPath, IntentMark.stepsMark,
          words: ['development', 'rolling', 'walking']),
      PpTool('A gentle check-in', 'A few questions, and when to ask your paediatrician.', 'pp_dev_checkin', tab: TtcTabMark.sunrise,
          IntentMark.lampMark, words: ['delay', 'worry']),
      // Named for where it lands: every activity for this age, not today's pick.
      // The door's "Things to do together today" now says the same (R3 settled 2026-10-25).
      PpTool('Activities', "Play ideas for your baby's age, by area of growing.", 'pp_activities', tab: TtcTabMark.twoFigures,
          IntentMark.playMark, words: ['play', 'games', 'activity']),
      // ⚠️ NOT A TOOL (tools pass D4, the user 2026-10-25: "why do we need to
      // include phases screens for tools?"). It opens reading pages in the
      // shared reader, and was listed here only because C1 saw it in the
      // Development door's Phases tab. Home, My Child, the door and Is my baby
      // OK? still open it; the C1 test allows it by name. Kept for revert:
      // PpTool("Your child's phases", 'What this phase is like, and what comes next.', 'pp_leaps',
      //     IntentMark.moonMark, words: ['phase', 'leap', 'wonder weeks']),
      // Folded into "Is my baby OK?" above (tools pass H2, 2026-10-25). Kept for revert:
      // PpTool('Something changed?', 'Sleep, feeding or mood suddenly different.', 'pp_what_changed',
      //     IntentMark.nextStep, words: ['regression', 'leap', 'fussy']),
      PpTool('What to say', 'Calm words for tantrums, hitting and big feelings.', 'pp_scripts', tab: TtcTabMark.twoBubbles,
          IntentMark.bookMark, words: ['tantrum', 'hitting', 'scripts', 'discipline']),
    ]),
    PpToolGroup('Food', 96, [
      PpTool('What to feed at this age', 'Portions and textures for this age, and signs of enough.', 'pp_food_chart', tab: TtcTabMark.sprout,
          IntentMark.plate, words: ['how much', 'portion', 'solids', 'enough']),
      // The count read from the list (was '289 foods', 2026-10-25).
      PpTool('Can my baby eat this?', '$ppBabyFoodCount foods, by age, with the reason.', 'pp_baby_food_check', tab: TtcTabMark.magnifier,
          IntentMark.forkMark, words: ['food', 'honey', 'egg', 'solids']),
      PpTool('Recipes', 'Indian home cooking for each age.', 'pp_food', tool: TtcToolMark.nutrition, IntentMark.cookMark,
          words: ['recipe', 'khichdi', 'meal']),
    ]),
    PpToolGroup('For you', 288, [
      PpTool('Can I...?', 'Quick answers for after the birth.', // was 'Quick answers while you breastfeed.' (2026-10-25: not every mother does)
           'pp_maa_can_i', tool: TtcToolMark.canI, IntentMark.lotusMark,
          words: ['medicine', 'chai', 'fasting']),
      PpTool('How have you been?', 'Four questions. No score, nothing saved.', // was 'Two questions.' (D1, 2026-10-25)
           'pp_mood_check', tab: TtcTabMark.heartHand,
          IntentMark.cuppedHands, words: ['mood', 'sad', 'low', 'anxious']),
      // Her own body after birth (2026-10-17: the user looked for Kegel Care
      // here and it was only inside the yoga hub and a pelvic floor page).
      PpTool('Kegel Care', 'Breathing first, then kegels from six weeks.', // was 'after your check': the date decides (2026-10-25)
           'pp_kegel', tab: TtcTabMark.tulip, IntentMark.spineMark,
          words: ['kegel', 'pelvic floor', 'leak', 'exercise']),
      PpTool('Yoga & fitness', 'Recovery classes, core and calm.', 'pp_yoga', tab: TtcTabMark.lotus, IntentMark.lotusMark,
          words: ['yoga', 'exercise', 'core', 'workout', 'postnatal']),
    ]),
    PpToolGroup('Plan and keep', 268, [
      // PpTool('Baby names', '2,031 names, with meaning, origin and Devanagari.', 'pp_names', tab: TtcTabMark.openBook, IntentMark.pageMark,
      //     words: ['name']), // kept for revert (tools pass 31): 2,031 was the count of catalogue lines, not names
      PpTool('Baby names', '${ppThousands(kBabyNames.length)} names, with meaning, origin and Devanagari.', 'pp_names',
          tab: TtcTabMark.openBook, IntentMark.pageMark, words: ['name']),
      // PpTool('Product guide', 'What is worth buying, and what to skip.', 'pp_product_guide', tab: TtcTabMark.wallet, IntentMark.bagMark,
      //     words: ['buy', 'products']), // kept for revert (tools pass 32): it opened the shop, the Products tab again
      // ⚠️ THE GUIDE OPENS THE GUIDES (tools pass 32, O4). The row promised
      // "what to skip" and landed on the storefront; the six real "how to
      // choose" guides were reachable only from the What to buy hub.
      PpTool('Product guide', 'How to choose a car seat, cot, pram, carrier and more.', 'pp_buying_guides',
          tab: TtcTabMark.wallet, IntentMark.bagMark, words: ['buy', 'products', 'choose', 'car seat', 'pram', 'cot']),
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
    // A tool not built yet says so (S8, 2026-10-25). Was a silent
    // `if (screen == null) return;`.
    if (ppSurfaceUnavailable(t.surfaceId) != null) {
      ppPushSurface(context, t.surfaceId);
      return;
    }
    final screen = ppScreenForSurface(t.surfaceId)!;
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
      leading: t.tab != null || t.tool != null
          ? TtcMarkLeading(tab: t.tab, tool: t.tool, tint: v2BlockTint(hue % 360, p))
          // The fallback for a row with no drawn mark of its own (none today).
          : ttcFamilyMarkForIntent(t.mark, v2BlockTint(hue % 360, p)) ??
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
        mark: const AskVedaMark(size: 20), // was icon: Icons.auto_awesome_outlined (Ask Veda mark, 2026-10-24)
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

/// 2040 -> "2,040" (tools pass 31): a count worked out, never typed.
String ppThousands(int n) {
  final d = '$n';
  final b = StringBuffer();
  for (var i = 0; i < d.length; i++) {
    if (i > 0 && (d.length - i) % 3 == 0) b.write(',');
    b.write(d[i]);
  }
  return b.toString();
}
