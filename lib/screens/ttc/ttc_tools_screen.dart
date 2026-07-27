// =============================================================================
//  TTC - Tools
// -----------------------------------------------------------------------------
//  "This becomes the largest feature after Today. Tools help. Tools do not
//   judge. Every tool exists even if unused."          - TTC master, §2.7
//
//  Every tile below is listed from day one, used or not - the same rule the
//  pregnancy Tools tab follows. A tool she has never opened must still teach
//  her it exists, so the grid never shrinks to "what you use".
//
//  Where a tile is not built yet it says so on tap rather than doing nothing.
//  The `built` flag on each entry is what the wiring test asserts against, so
//  a tile cannot quietly claim to work.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_supplements_store.dart';
import '../../ttc/ttc_trackers_data.dart';
import 'ttc_appointments_screen.dart';
import 'ttc_can_i_screen.dart';
import 'ttc_common.dart';
import 'ttc_cycle_screens.dart';
import 'ttc_journal_screen.dart';
import 'ttc_journey_map_screen.dart';
import 'ttc_nutrition_screen.dart';
import 'ttc_products_screen.dart';
import 'ttc_records_screen.dart';
import 'ttc_strings.dart';
import 'ttc_supplements_screen.dart';
import 'ttc_tests_screen.dart';
import 'ttc_tracker_screen.dart';

/// One tile in the hub.
class TtcTool {
  const TtcTool({
    required this.id,
    required this.icon,
    required this.nameEn,
    required this.nameHi,
    required this.open,
    this.descEn = '',
    this.descHi = '',
    this.built = true,
  });

  final String id;
  final IconData icon;
  final String nameEn;
  final String nameHi;

  /// Three or four words on what the tool is for.
  ///
  /// Bare labels left the hub unreadable: nothing distinguished Mood from
  /// Stress from Lifestyle, and the whitespace for a line of explanation was
  /// already sitting there unused. Shown only until the tile has something of
  /// hers in it - after that the state line is the more useful thing to say.
  final String descEn;
  final String descHi;

  String desc(bool hi) => hi ? descHi : descEn;

  /// What tapping it does. Never null - a tile that does nothing reads as a bug.
  final void Function(BuildContext) open;

  /// False for tiles whose destination arrives in a later phase. Pinned by test
  /// so a tile cannot silently pretend to be finished.
  final bool built;

  String name(bool hi) => hi ? nameHi : nameEn;
}

class TtcToolGroup {
  const TtcToolGroup({
    required this.titleEn,
    required this.titleHi,
    required this.tools,
  });

  final String titleEn;
  final String titleHi;
  final List<TtcTool> tools;

  String title(bool hi) => hi ? titleHi : titleEn;
}

/// The twenty-two tools named in the master document, §2.7, grouped the way the
/// pregnancy hub groups its own.
final List<TtcToolGroup> ttcToolGroups = [
  TtcToolGroup(
    titleEn: 'Your body',
    titleHi: 'Aapka body',
    tools: [
      TtcTool(
        id: 'cycle',
        icon: Icons.favorite_outline_rounded,
        nameEn: 'Cycle Companion',
        nameHi: 'Cycle Companion',
        descEn: 'Your periods, and what they say',
        descHi: 'Aapke periods, aur unka matlab',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcCycleScreen(),
            settings: const RouteSettings(name: 'ttc/cycle'))),
      ),
      TtcTool(
        id: 'ovulation',
        icon: Icons.egg_outlined,
        nameEn: 'Ovulation Companion',
        nameHi: 'Ovulation Companion',
        descEn: 'Signs your body gives',
        descHi: 'Body ke ishaare',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcOvulationScreen(),
            settings: const RouteSettings(name: 'ttc/ovulation'))),
      ),
      TtcTool(
        id: 'window',
        icon: Icons.wb_twilight_rounded,
        nameEn: 'Fertility Window',
        nameHi: 'Fertility Window',
        descEn: 'The days that matter most',
        descHi: 'Sabse ahem din',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcFertilityWindowScreen(),
            settings: const RouteSettings(name: 'ttc/window'))),
      ),
      TtcTool(
        id: 'symptoms',
        icon: Icons.healing_outlined,
        nameEn: 'Symptom Companion',
        nameHi: 'Symptom Companion',
        descEn: 'Notice patterns, never diagnose',
        descHi: 'Pattern dekhein, diagnose nahi',
        open: (c) => openTtcTracker(c, 'symptoms'),
      ),
      TtcTool(
        id: 'weight',
        icon: Icons.monitor_weight_outlined,
        nameEn: 'Weight',
        nameHi: 'Wazan',
        descEn: 'A number, not a verdict',
        descHi: 'Ek number, faisla nahi',
        open: (c) => openTtcTracker(c, 'weight'),
      ),
      TtcTool(
        id: 'sleep',
        icon: Icons.bedtime_outlined,
        nameEn: 'Sleep',
        nameHi: 'Neend',
        descEn: 'Hours, and how they felt',
        descHi: 'Ghante, aur kaisa laga',
        open: (c) => openTtcTracker(c, 'sleep'),
      ),
    ],
  ),
  TtcToolGroup(
    titleEn: 'Both of you',
    titleHi: 'Aap dono',
    tools: [
      TtcTool(
        id: 'partner_health',
        icon: Icons.male_rounded,
        nameEn: 'Partner Health',
        nameHi: 'Partner ki sehat',
        descEn: 'His half of this',
        descHi: 'Unka aadha hissa',
        open: (c) => openTtcTracker(c, 'partner_health'),
      ),
      TtcTool(
        id: 'mood',
        icon: Icons.mood_outlined,
        nameEn: 'Mood',
        nameHi: 'Mood',
        descEn: 'How the day actually felt',
        descHi: 'Din asal mein kaisa tha',
        open: (c) => openTtcTracker(c, 'mood'),
      ),
      TtcTool(
        id: 'stress',
        icon: Icons.spa_outlined,
        nameEn: 'Stress',
        nameHi: 'Stress',
        descEn: 'What is weighing on you',
        descHi: 'Kya bojh mehsoos ho raha',
        open: (c) => openTtcTracker(c, 'stress'),
      ),
      TtcTool(
        id: 'lifestyle',
        icon: Icons.wb_sunny_outlined,
        nameEn: 'Lifestyle',
        nameHi: 'Lifestyle',
        descEn: 'Habits worth a small change',
        descHi: 'Aadatein jinme chhota badlaav',
        open: (c) => openTtcTracker(c, 'lifestyle'),
      ),
      TtcTool(
        id: 'journal',
        icon: Icons.edit_note_rounded,
        nameEn: 'Journal',
        nameHi: 'Journal',
        descEn: 'Both of you can write here',
        descHi: 'Aap dono yahan likh sakte hain',
        open: openTtcJournal,
      ),
    ],
  ),
  TtcToolGroup(
    titleEn: 'Care and medicines',
    titleHi: 'Dekhbhaal aur dawaiyan',
    tools: [
      TtcTool(
        id: 'supplements',
        icon: Icons.medication_outlined,
        nameEn: 'Supplements & medication',
        nameHi: 'Supplements aur dawaiyan',
        descEn: 'One list of what you take',
        descHi: 'Jo aap lete hain, ek list',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcSupplementsScreen(),
            settings: const RouteSettings(name: 'ttc/supplements'))),
      ),
      TtcTool(
        id: 'tests',
        icon: Icons.biotech_outlined,
        nameEn: 'Medical Tests',
        nameHi: 'Medical Tests',
        descEn: 'What each one tells you',
        descHi: 'Har test kya batata hai',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcTestsScreen(),
            settings: const RouteSettings(name: 'ttc/tests'))),
      ),
      TtcTool(
        id: 'records',
        icon: Icons.folder_shared_outlined,
        nameEn: 'Records & reports',
        nameHi: 'Records aur reports',
        descEn: 'Both of your results, one place',
        descHi: 'Dono ke results, ek jagah',
        open: openTtcRecords,
      ),
      TtcTool(
        id: 'appointments',
        icon: Icons.event_note_outlined,
        nameEn: 'Appointments',
        nameHi: 'Appointments',
        descEn: 'Visits, and what to ask',
        descHi: 'Visits, aur kya poochhna hai',
        open: openTtcAppointments,
      ),
    ],
  ),
  TtcToolGroup(
    titleEn: 'Plan and learn',
    titleHi: 'Plan aur seekhein',
    tools: [
      TtcTool(
        id: 'exercise',
        icon: Icons.directions_walk_rounded,
        nameEn: 'Movement',
        nameHi: 'Movement',
        descEn: 'Movement that helps',
        descHi: 'Jo movement madad kare',
        open: (c) => openTtcTracker(c, 'exercise'),
      ),
      TtcTool(
        id: 'nutrition',
        icon: Icons.restaurant_outlined,
        nameEn: 'Nutrition Planner',
        nameHi: 'Nutrition Planner',
        descEn: 'A week of ideas, not a plan',
        descHi: 'Hafte bhar ke ideas, plan nahi',
        open: openTtcNutrition,
      ),
      TtcTool(
        id: 'map',
        icon: Icons.map_outlined,
        nameEn: 'Journey Map',
        nameHi: 'Journey Map',
        descEn: 'The whole journey, at a glance',
        descHi: 'Poora safar, ek nazar mein',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcJourneyMapScreen(),
            settings: const RouteSettings(name: 'ttc/map'))),
      ),
      TtcTool(
        id: 'canI',
        icon: Icons.help_outline_rounded,
        nameEn: 'Can I...?',
        nameHi: 'Kya main...?',
        descEn: 'The everyday worries, settled',
        descHi: 'Rozmarra ki chinta, hal',
        open: openTtcCanI,
      ),
      TtcTool(
        id: 'guide',
        icon: Icons.verified_outlined,
        nameEn: 'Worth knowing about',
        nameHi: 'Jaanne layak',
        descEn: 'Research first, buy second',
        descHi: 'Pehle research, phir kharid',
        open: openTtcProducts,
      ),
    ],
  ),
];

class TtcToolsScreen extends StatelessWidget {
  const TtcToolsScreen({super.key});

  /// Total tile count, asserted in tests against the master document's 22.
  static int get toolCount =>
      ttcToolGroups.fold(0, (n, g) => n + g.tools.length);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcLang.instance,
        TtcLogStore.instance,
        TtcSupplementsStore.instance,
        TtcRecordsStore.instance,
        TtcAppointmentsStore.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        return TtcPage(
          tab: 2,
          header: const TtcHeader(),
          children: [
            ttcSectionTitle(t.toolsTitle, eyebrow: t.tabTools),
            Text(t.toolsBody, style: ttcBody(14, h: 1.6)),
            const SizedBox(height: 20),
            for (final group in ttcToolGroups) ...[
              ttcEyebrow(group.title(hi), color: ttcPurple),
              const SizedBox(height: 11),
              for (var i = 0; i < group.tools.length; i += 2) ...[
                // IntrinsicHeight so a tile with a subtitle and one without
                // still line up. Plain CrossAxisAlignment.stretch cannot be
                // used here: inside a ListView it forces an infinite height
                // constraint and the tab fails to lay out at all.
                IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _tile(context, group.tools[i], hi, t)),
                        const SizedBox(width: 11),
                        Expanded(
                          child: i + 1 < group.tools.length
                              ? _tile(context, group.tools[i + 1], hi, t)
                              : const SizedBox(),
                        ),
                      ]),
                ),
                const SizedBox(height: 11),
              ],
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }

  Widget _tile(BuildContext context, TtcTool tool, bool hi, TtcS t) {
    // A quiet marker of what has been logged, so an opened tool feels different
    // from an untouched one - without ever becoming a score.
    final subtitle = _subtitleFor(tool, hi);
    // A tile she has used says what is in it; one she has not says what it is
    // for. Both beat a bare label with empty space under it.
    final under = subtitle ?? (tool.desc(hi).isEmpty ? null : tool.desc(hi));

    return TtcCard(
      onTap: () => tool.open(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // The icon sits in a tinted chip, the way the pregnancy hub does
            // it. A bare glyph on white gave every tool the same weight and
            // made the grid read as a list of words.
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ttcPanel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tool.icon, size: 20, color: ttcPurple),
            ),
            const SizedBox(height: 11),
            Text(tool.name(hi),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ttcJakarta(13.5)),
            if (under != null) ...[
              const SizedBox(height: 4),
              Text(under,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ttcBody(10.5, color: ttcMuted, w: FontWeight.w600, h: 1.35)),
            ],
            const SizedBox(height: 10),
            // An explicit action, like pregnancy's "Open →". The whole card was
            // already tappable; nothing on it said so.
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(t.openTool,
                  style: ttcBody(11, color: ttcPurple, w: FontWeight.w800)),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_forward_rounded,
                  size: 13, color: ttcPurple),
            ]),
          ]),
    );
  }

  /// A quiet line under a tile once there is something to say about it. Never a
  /// count of what is missing, never a percentage, never a nudge - just a sign
  /// that the tool holds something of theirs.
  String? _subtitleFor(TtcTool tool, bool hi) {
    if (!tool.built) return hi ? 'Jald' : 'Soon';
    switch (tool.id) {
      case 'supplements':
      case 'medication':
        final n = TtcSupplementsStore.instance.items.length;
        if (n == 0) return null;
        return hi ? '$n add kiye' : '$n added';
      case 'reports':
      case 'records':
        final n = TtcRecordsStore.instance.count;
        if (n == 0) return null;
        return hi ? '$n record' : '$n saved';
      case 'appointments':
        final n = TtcAppointmentsStore.instance.upcoming.length;
        if (n == 0) return null;
        return hi ? '$n aage' : '$n upcoming';
      default:
        // The tracker tiles share one store, so one lookup covers all of them.
        if (ttcTrackerById(tool.id) == null) return null;
        final days = TtcLogStore.instance.daysLogged(tool.id).length;
        if (days == 0) return null;
        return hi ? '$days din log kiye' : '$days days logged';
    }
  }
}
