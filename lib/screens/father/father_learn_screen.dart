// =============================================================================
//  FatherLearnScreen — the father's "Learn" tab (2026-09-30)
// -----------------------------------------------------------------------------
//  The skeleton, not the skin. The partner bar's third tab was "Reads": one Slate
//  list of articles, research summaries, books and tales. Her bar has a Learn tab
//  that lists the topics (doors) she can open; his now does the same, in the same
//  order of ideas, over the For partners door (pv_door_partner.dart):
//
//    Your week, week by week   (the guide drawn from `WeekContent.partner`)
//    Start with the five topics of the door, each opening the door on that tab
//    More reads, research and stories  (the old Reads list, kept whole)
//
//  ⚠️ THE OLD LIST IS NOT REMOVED, IT MOVED ONE TAP IN. `FatherReadsScreen` is
//  unchanged and opens from the last row (a pushed page, so it gets a back
//  button); everything it offered is still reachable. Kept for revert: the
//  partner bar's third page was `const FatherReadsScreen()`.
//
//  The look is the Slate skin as it was (father_skin.dart); the user's call
//  (2026-09-30) is that the design pass comes later.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_partner.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/father_skin.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_screen.dart';
import 'father_reads_screen.dart';
import 'father_week_guide_screen.dart';

/// One topic row: the door's tab it opens, and what is in it.
class FatherLearnTopic {
  const FatherLearnTopic(this.tab, this.title, this.line, this.icon);
  final String tab;
  final String title;
  final String line;
  final IconData icon;
}

/// The door's five tabs, as topics. The tab ids are the door's own, so a tab that
/// is renamed or removed there fails `test/father_side_test.dart` here.
const List<FatherLearnTopic> kFatherLearnTopics = [
  FatherLearnTopic(kPartnerTabWeek, 'Start here',
      'The first days after the news, and what to do in each trimester', Icons.flag_outlined),
  FatherLearnTopic(kPartnerTabSupport, 'Supporting her',
      'Small things that help, helping with feeding, and time together', Icons.favorite_border_rounded),
  FatherLearnTopic(kPartnerTabBirth, 'Labour and birth',
      'Your jobs on the day, when to go in, and what may happen', Icons.child_friendly_outlined),
  FatherLearnTopic(kPartnerTabYou, 'You, too',
      'Your own feelings, pregnancy symptoms of your own, and if it ends', Icons.self_improvement_rounded),
  FatherLearnTopic(kPartnerTabReady, 'Before the baby',
      'Seven things to do first, the bag, and what to buy', Icons.home_outlined),
];

class FatherLearnScreen extends StatelessWidget {
  const FatherLearnScreen({super.key, required this.controller});
  final PregnancyController controller;

  void _openDoor(BuildContext context, String tab) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'bracket/partner'),
      builder: (_) => PvDoorScreen(
          page: kPartnerDoor, bracket: kPregPartnerBracket, pregnancy: controller, initialGroup: tab),
    ));
  }

  void _openOldReads(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'partner/reads'),
      builder: (_) => Scaffold(
        backgroundColor: kFBg,
        appBar: AppBar(
          backgroundColor: kFBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: kFInk),
        ),
        body: const FatherReadsScreen(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Container(
        color: kFBg,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
            children: [
              Text('FOR PARTNERS',
                  style: pvJakarta(fontSize: 11, fontWeight: FontWeight.w700, color: kFMuted, letterSpacing: 1.4)),
              const SizedBox(height: 4),
              Text('Learn', style: fatherSerif(26, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Everything written for you, in one place. Nothing here is about her private health.',
                  style: pvJakarta(fontSize: 13, color: kFMuted, height: 1.5)),
              const SizedBox(height: 18),
              _Row(
                key: const ValueKey('father_learn_week_guide'),
                icon: Icons.calendar_today_outlined,
                title: 'Your week, week by week',
                line: 'What she may feel and what you can do, for every week',
                onTap: () => openFatherWeekGuide(context, controller),
              ),
              const SizedBox(height: 10),
              for (final t in kFatherLearnTopics) ...[
                _Row(
                  key: ValueKey('father_learn_${t.tab}'),
                  icon: t.icon,
                  title: t.title,
                  line: t.line,
                  onTap: () => _openDoor(context, t.tab),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              _Row(
                key: const ValueKey('father_learn_more_reads'),
                icon: Icons.menu_book_outlined,
                title: 'More reads, research and stories',
                line: 'Articles, research summaries, books and tales',
                onTap: () => _openOldReads(context),
              ),
            ],
          ),
        ),
      );
}

class _Row extends StatelessWidget {
  const _Row({super.key, required this.icon, required this.title, required this.line, required this.onTap});
  final IconData icon;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kFCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kFLine),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: kFAccentSoft, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: kFAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: pvJakarta(fontSize: 14.5, fontWeight: FontWeight.w700, color: kFInk)),
                const SizedBox(height: 2),
                Text(line, style: pvJakarta(fontSize: 12.5, color: kFMuted, height: 1.4)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: kFMuted),
          ]),
        ),
      );
}
