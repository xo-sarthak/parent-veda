// =============================================================================
//  TTC - Journey Map
// -----------------------------------------------------------------------------
//  Pregnancy's Journey Map is a trail of week nodes. TTC's is a trail of
//  CHAPTERS, plus everything the couple has actually done. (Master doc §2.8)
//
//  The hardest design problem on this screen: chapters 2-4 repeat with every
//  cycle. A trail that visibly walked backwards each month would be the
//  cruellest object in the product. So the chapters are drawn as a LOOP with a
//  "you are here" marker rather than as a line with a finish, and the thing
//  that only ever grows is the milestone list underneath.
//
//  Milestones are effort, not outcome - exactly one of them is an outcome, and
//  a couple two years in can still see a long list of things they have done.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/family_timeline.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_milestones.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_chapter_screen.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_timeline_screen.dart';

class TtcJourneyMapScreen extends StatelessWidget {
  const TtcJourneyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [TtcStore.instance, FamilyTimeline.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        const engine = TtcMilestoneEngine();
        // Reaching a milestone writes it into the family's life story. Safe on
        // every build - FamilyTimeline.add is idempotent on the event id.
        engine.syncToTimeline();

        final current = TtcStore.instance.today.chapter;
        final achieved = engine.achieved;
        final ahead = engine.ahead;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.journeyMap),
                const SizedBox(height: 16),
                Text(t.journeyMapIntro, style: ttcBody(13.5, h: 1.6)),
                const SizedBox(height: 20),

                // ---- the chapter trail ------------------------------------
                for (final chapter in TtcChapter.values)
                  _ChapterNode(
                    chapter: chapter,
                    current: chapter == current,
                    last: chapter == TtcChapter.values.last,
                    t: t,
                  ),

                const SizedBox(height: 24),

                // ---- what they have done ----------------------------------
                ttcSectionTitle(t.milestones,
                    trailing: Text('${achieved.length}',
                        style: ttcJakarta(16, color: ttcPurple))),
                if (achieved.isEmpty)
                  TtcCard(
                    color: ttcPanel,
                    child: Text(t.milestonesNone, style: ttcBody(13.5, h: 1.5)),
                  )
                else
                  for (final m in achieved) ...[
                    _MilestoneCard(milestone: m, done: true, t: t),
                    const SizedBox(height: 10),
                  ],

                if (ahead.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  // "Still ahead", never "missing" and never a count of what is
                  // undone. Warm language is a contract.
                  ttcSectionTitle(t.milestonesAhead),
                  for (final m in ahead) ...[
                    _MilestoneCard(milestone: m, done: false, t: t),
                    const SizedBox(height: 10),
                  ],
                ],

                const SizedBox(height: 18),
                TtcCard(
                  onTap: () => openTtcTimeline(context),
                  child: Row(children: [
                    const Icon(Icons.timeline_rounded, size: 19, color: ttcPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.familyTimeline, style: ttcJakarta(15.5)),
                            const SizedBox(height: 3),
                            Text(
                                hi
                                    ? 'Poori kahani, ek jagah'
                                    : 'The whole story, in one place',
                                style: ttcBody(12.5)),
                          ]),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 17, color: ttcMuted),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChapterNode extends StatelessWidget {
  const _ChapterNode({
    required this.chapter,
    required this.current,
    required this.last,
    required this.t,
  });

  final TtcChapter chapter;
  final bool current;
  final bool last;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    // Chapters 2-4 loop. Marked as such rather than drawn as a line, so nobody
    // reads a repeat as going backwards.
    final loops = chapter == TtcChapter.knowingYourRhythm ||
        chapter == TtcChapter.tryingTogether ||
        chapter == TtcChapter.theWaitingDays;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // The trail itself.
        Column(children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: current ? ttcPurple : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: current ? ttcPurple : ttcBorder, width: 2),
            ),
            child: current
                ? const Icon(Icons.circle, size: 8, color: Colors.white)
                : Text('${chapter.number}',
                    style: ttcBody(11, color: ttcMuted, w: FontWeight.w800)),
          ),
          if (!last)
            Expanded(
              child: Container(width: 2, color: ttcLine),
            ),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 14),
            child: TtcCard(
              onTap: () => openTtcChapter(context, chapter),
              padding: const EdgeInsets.all(16),
              color: current ? ttcPanel : Colors.white,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(chapter.title(hi), style: ttcJakarta(15.5))),
                      if (current)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                              color: ttcPurple,
                              borderRadius: BorderRadius.circular(999)),
                          child: Text(t.chapterYouAreHere,
                              style: ttcBody(9.5,
                                  color: Colors.white, w: FontWeight.w800)),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    Text(chapter.focus(hi), style: ttcBody(12.5)),
                    if (loops) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.loop_rounded, size: 13, color: ttcMuted),
                        const SizedBox(width: 6),
                        Text(
                            hi
                                ? 'Har cycle mein dobara aata hai'
                                : 'Comes round each cycle',
                            style: ttcBody(11, color: ttcMuted, w: FontWeight.w600)),
                      ]),
                    ],
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.milestone,
    required this.done,
    required this.t,
  });

  final TtcMilestone milestone;
  final bool done;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return TtcCard(
      padding: const EdgeInsets.all(15),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? ttcPanel : ttcBg,
            shape: BoxShape.circle,
            border: done ? null : Border.all(color: ttcLine),
          ),
          child: Icon(_icon(milestone.iconKey),
              size: 17, color: done ? ttcPurple : ttcMuted),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(milestone.title(hi),
                style: ttcJakarta(14.5,
                    color: done ? ttcTitleInk : ttcSoft)),
            const SizedBox(height: 4),
            Text(milestone.body(hi), style: ttcBody(12.5, h: 1.5)),
          ]),
        ),
        if (done)
          const Padding(
            padding: EdgeInsets.only(left: 8, top: 2),
            child: Icon(Icons.check_circle_rounded, size: 18, color: ttcPurple),
          ),
      ]),
    );
  }

  IconData _icon(String key) {
    switch (key) {
      case 'flag':
        return Icons.flag_outlined;
      case 'pill':
        return Icons.medication_outlined;
      case 'cycle':
        return Icons.favorite_outline_rounded;
      case 'loop':
        return Icons.loop_rounded;
      case 'egg':
        return Icons.egg_outlined;
      case 'people':
        return Icons.people_outline_rounded;
      case 'test':
        return Icons.biotech_outlined;
      case 'write':
        return Icons.edit_outlined;
      case 'spa':
        return Icons.spa_outlined;
      case 'sun':
        return Icons.wb_sunny_outlined;
      case 'star':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}
