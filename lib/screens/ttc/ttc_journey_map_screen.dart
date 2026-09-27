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
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT AS A TRAIL YOU CAN ACT FROM (tool rebuild, 2026-09-27, night)
//  ---------------------------------------------------------------------------
//  "Old tools in new clothes": five shadowed cards on a violet rail, a purple
//  "You are here" pill, and two lists of milestone cards that did nothing when
//  tapped. "Still ahead" named eleven things she could do and gave her no way
//  to do any of them. Now (Bumble "Your report",
//  https://mobbin.com/screens/09426d05-9e3c-4a74-b206-da7d04e07ba4; Hers
//  "Consultation", https://mobbin.com/screens/f2441dba-a083-45a2-897a-1dd84d0b8fb4;
//  Superpower "complete your twin",
//  https://mobbin.com/screens/4e433304-5b2b-4a6c-b6f4-9f84fe0b77b1):
//
//    · The chapters as a hairline rail: a ring per chapter, the one she is in
//      filled in ink with "You are here". Text beside the rail, no boxes. The
//      loop stays drawn (a hairline box around chapters two to four).
//    · "Still ahead" rows each say what to do and go there: "Write in the
//      journal", "Add your supplements", "Invite your partner". The two that
//      no tap can bring say so plainly.
//    · "What you've done" rows open where the thing lives.
//    · The count is gone. A number next to effort reads as a score.
//  The milestone engine and its timeline writes are unchanged.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/family_timeline.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_milestones.dart';
import '../../ttc/ttc_store.dart';
import '../doors/pv_list_row.dart' show PvRowGroup;
import '../v2/v2_palette.dart';
import 'ttc_chapter_screen.dart';
import 'ttc_lookup_parts.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart' show openTtcSurface;
import 'ttc_timeline_screen.dart';
import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_tool_chrome.dart';

/// Where each milestone lives, and the plain action that reaches it
/// (2026-09-27, night). `surface` opens once it is done ("where is it?");
/// `action` is the words on the row while it is still ahead ("how do I?").
/// A milestone with no action comes by itself and its row says so.
///
/// ⚠️ THE ACTION IS WHAT THE ENGINE ACTUALLY COUNTS. `tests_done` is reached
/// by logging a weight (`TtcMilestoneEngine.isAchieved`), so its action says
/// "Log your weight", not "Add a test result", which would not tick it.
const Map<String, ({String? surface, String? action, String? byItself})>
    kTtcMilestoneWays = {
  'journey_started': (surface: null, action: null, byItself: null),
  'supplements_started':
      (surface: 'ttc_supplements', action: 'Add your supplements', byItself: null),
  'first_cycle_logged':
      (surface: 'ttc_calendar', action: 'Log a period', byItself: null),
  'first_cycle_complete': (
    surface: 'ttc_cycle_report',
    action: null,
    byItself: 'Comes by itself when your next period starts.'
  ),
  'ovulation_learned': (
    surface: 'ttc_window',
    action: 'Log an ovulation test or your temperature',
    byItself: null
  ),
  'partner_joined':
      (surface: 'ttc_care_circle', action: 'Invite your partner', byItself: null),
  'tests_done':
      (surface: 'ttc_symptom_log', action: 'Log your weight', byItself: null),
  'wrote_something':
      (surface: 'ttc_journal', action: 'Write in the journal', byItself: null),
  'ritual_week':
      (surface: 'ttc_ritual', action: 'Open your daily ritual', byItself: null),
  'lifestyle_tracked': (
    surface: 'ttc_habits',
    action: 'Track your sleep or movement',
    byItself: null
  ),
  'positive_test': (surface: null, action: null, byItself: 'Whenever it comes.'),
};

/// Opens where a milestone is DONE ([ahead] false) or where it is REACHED
/// ([ahead] true). Logging a period opens the period sheet itself.
void openTtcMilestoneWay(BuildContext context, String id, {required bool ahead}) {
  if (ahead && id == 'first_cycle_logged') {
    logTtcPeriod(context);
    return;
  }
  final way = kTtcMilestoneWays[id];
  final surface = ahead
      ? (way?.action == null ? null : way?.surface)
      : way?.surface;
  if (surface != null) openTtcSurface(context, surface);
}

/// The surface a timeline row written by the milestone engine opens, or null.
String? ttcTimelineSurface(String eventId) {
  const prefix = 'ttc_ms_';
  if (!eventId.startsWith(prefix)) return null;
  return kTtcMilestoneWays[eventId.substring(prefix.length)]?.surface;
}

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
        final p = V2PaletteStore.instance.current;
        const engine = TtcMilestoneEngine();
        // Reaching a milestone writes it into the family's life story. Safe on
        // every build - FamilyTimeline.add is idempotent on the event id.
        engine.syncToTimeline();

        final current = TtcStore.instance.today.chapter;
        final achieved = engine.achieved;
        final ahead = engine.ahead;

        Widget step(TtcChapter c, {required bool last}) => _ChapterStep(
              chapter: c,
              current: c == current,
              last: last,
              t: t,
            );

        return TtcToolScaffold(
          // Plan and learn's hue in Tools.
          hue: 104,
          // ⚠️ ONE NAME (2026-09-27): the tile says "Journey map", so
          // the page does too, as the eyebrow, word for word; the title is
          // the tile's own line. Kept for revert: `t.journeyMap`.
          eyebrow: hi ? t.journeyMap : 'Journey map',
          title: 'Where you are this month, and what comes next.',
          // ⚠️ WHAT THIS IS, FIRST, AND WHAT "CHAPTER" MEANS
          // (2026-09-27). Kept for revert: `t.journeyMapIntro`.
          intro: hi
              ? t.journeyMapIntro
              : 'We split trying for a baby into five parts, called '
                  'chapters. The middle three come round again every '
                  "cycle, from one period to the next. That's normal, "
                  "and it isn't a step backwards. Tap a chapter to "
                  'read about it.',
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TtcLookupHeading('Your chapters'),
                const SizedBox(height: 6),
                step(TtcChapter.preparingTogether, last: false),
                _CycleLoop(children: [
                  step(TtcChapter.knowingYourRhythm, last: false),
                  step(TtcChapter.tryingTogether, last: false),
                  step(TtcChapter.theWaitingDays, last: true),
                ]),
                const SizedBox(height: 14),
                step(TtcChapter.aNewBeginning, last: true),

                // ---- still ahead: each row says how, and goes there -------
                // Before "done" now: it is the half she can act on.
                if (ahead.isNotEmpty) ...[
                  // "Still ahead", never "missing" and never a count of what
                  // is undone. Warm language is a contract.
                  TtcLookupHeading(t.milestonesAhead, top: 30),
                  PvRowGroup(p: p, children: [
                    for (final m in ahead) _MilestoneRow(milestone: m, done: false, t: t),
                  ]),
                ],

                // ---- what they have done ----------------------------------
                // ⚠️ NO COUNT AT ALL (2026-09-27, night). The pass before hid
                // the big "0"; a "3" beside effort still reads as a score.
                // Kept for revert: the trailing count when achieved was not
                // empty.
                TtcLookupHeading(t.milestones, top: 30),
                if (achieved.isEmpty)
                  Text(t.milestonesNone, style: ttcLookupBody(p))
                else
                  PvRowGroup(p: p, children: [
                    for (final m in achieved) _MilestoneRow(milestone: m, done: true, t: t),
                  ]),

                const TtcLookupHeading('Your story', top: 30),
                PvRowGroup(p: p, children: [
                  TtcLookupActionRow(
                    key: const ValueKey('ttc_map_timeline'),
                    icon: Icons.timeline_rounded,
                    label: hi ? t.familyTimeline : 'Family timeline',
                    line: hi
                        ? 'Poori kahani, ek jagah'
                        : 'Everything you have done, in date order.',
                    onTap: () => openTtcTimeline(context),
                  ),
                ]),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }
}

/// One chapter on the rail: a ring (ink when she is in it), the name, which
/// part of the month it is, and what brings the next one.
class _ChapterStep extends StatelessWidget {
  const _ChapterStep({
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
    final p = V2PaletteStore.instance.current;
    return InkWell(
      onTap: () => openTtcChapter(context, chapter),
      borderRadius: BorderRadius.circular(14),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 26,
            child: Column(children: [
              const SizedBox(height: 2),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: current ? p.ink1 : p.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: current ? p.ink1 : p.line, width: 1.5),
                ),
                child: current
                    ? Icon(Icons.circle, size: 8, color: p.surface)
                    : Text('${chapter.number}',
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: p.ink2)),
              ),
              if (!last)
                Expanded(child: Container(width: 1.5, color: p.line)),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 4 : 18, top: 3),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Text(chapter.title(hi),
                            style: pvManrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                                color: p.ink1)),
                      ),
                      if (current) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                              color: p.ink1,
                              borderRadius: BorderRadius.circular(999)),
                          child: Text(t.chapterYouAreHere,
                              style: pvManrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: p.surface)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 4),
                    // ⚠️ WHAT PART OF THE MONTH, NOT A THEME (2026-09-27).
                    // Kept for revert: Text(chapter.focus(hi), ...).
                    Text(hi ? chapter.focus(hi) : ttcChapterPlainPart(chapter),
                        style: pvManrope(
                            fontSize: 13, height: 1.45, color: p.ink2)),
                    const SizedBox(height: 5),
                    // What brings the next chapter, on every step. Same copy
                    // the Today hero uses, so the two cannot drift.
                    Text(chapter.nextUp(hi),
                        style: pvManrope(
                            fontSize: 12,
                            height: 1.45,
                            fontWeight:
                                current ? FontWeight.w700 : FontWeight.w500,
                            color: current ? p.ink1 : p.ink3)),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// One milestone: done (a filled tick, opens where it lives) or ahead (a
/// ring, and the plain action that reaches it).
class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
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
    final p = V2PaletteStore.instance.current;
    final way = kTtcMilestoneWays[milestone.id];
    final tappable = done ? way?.surface != null : way?.action != null;
    return TtcLookupRow(
      key: ValueKey('ttc_map_ms_${milestone.id}'),
      title: milestone.title(hi),
      onTap: tappable
          ? () => openTtcMilestoneWay(context, milestone.id, ahead: !done)
          : null,
      leading: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: done ? p.ink1 : p.surface,
          shape: BoxShape.circle,
          border: done ? null : Border.all(color: p.line, width: 1.5),
        ),
        child: Icon(done ? Icons.check_rounded : _icon(milestone.iconKey),
            size: 16, color: done ? p.surface : p.ink2),
      ),
      lines: [
        if (done)
          ttcLookupLine(milestone.body(hi))
        else if (way?.action case final action?)
          ttcLookupLine(action, strong: true, maxLines: 1)
        else if (way?.byItself case final line?)
          ttcLookupLine(line)
        else
          ttcLookupLine(milestone.body(hi)),
      ],
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

/// Chapters two to four, drawn as the loop they are: a hairline box headed by
/// what repeats and closed by what starts it again. English only (new copy).
class _CycleLoop extends StatelessWidget {
  const _CycleLoop({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      key: const ValueKey('ttc_map_cycle_loop'),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.loop_rounded, size: 16, color: p.ink1),
          const SizedBox(width: 8),
          Expanded(
            child: Text('These three repeat every cycle',
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w800, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.u_turn_left_rounded, size: 16, color: p.ink3),
          const SizedBox(width: 8),
          Expanded(
            child: Text('A new period starts the loop again',
                style: pvManrope(
                    fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
          ),
        ]),
      ]),
    );
  }
}

// =============================================================================
//  Kept for revert (2026-09-27, night): the build, the chapter card, the
//  milestone card and the tinted loop as they were before the tool rebuild.
// =============================================================================
// class TtcJourneyMapScreen extends StatelessWidget {
//   const TtcJourneyMapScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: Listenable.merge(
//           [TtcStore.instance, FamilyTimeline.instance, TtcLang.instance]),
//       builder: (context, _) {
//         final t = TtcS.current();
//         final hi = t.hinglish;
//         const engine = TtcMilestoneEngine();
//         // Reaching a milestone writes it into the family's life story. Safe on
//         // every build - FamilyTimeline.add is idempotent on the event id.
//         engine.syncToTimeline();
//
//         final current = TtcStore.instance.today.chapter;
//         final achieved = engine.achieved;
//         final ahead = engine.ahead;
//
//         // ⚠️ ONE SHELL FOR EVERY TOOL (2026-09-27). Tiles in the same Tools
//         // hub opened in two different shells: most wore `TtcToolScaffold`
//         // (hero field, serif title, white sheet) and this one a plain page
//         // with a back bar. Only the shell changed: the tile's name is the
//         // hero title, the what-this-is line is the hero intro, and the
//         // trail, loop box and milestones sit in the sheet unchanged.
//         // Kept for revert (2026-09-27):
//         // return Scaffold(
//         //   backgroundColor: ttcBg,
//         //   body: SafeArea(
//         //     child: ListView(
//         //       padding: const EdgeInsets.fromLTRB(
//         //           ttcGutter, 8, ttcGutter, ttcBottomInset),
//         //       children: [
//         //         TtcBackBar(title: hi ? t.journeyMap : 'Journey map'),
//         //         const SizedBox(height: 16),
//         //         Text(<the intro below>, style: ttcBody(13.5, h: 1.6)),
//         //         const SizedBox(height: 20),
//         return TtcToolScaffold(
//           // Plan and learn's hue in Tools.
//           hue: 104,
//           // ⚠️ ONE NAME (2026-09-27): the tile says "Journey map", so
//           // the page does too, as the eyebrow, word for word; the title is
//           // the tile's own line. Kept for revert: `t.journeyMap`.
//           eyebrow: hi ? t.journeyMap : 'Journey map',
//           title: 'Where you are this month, and what comes next.',
//           // ⚠️ WHAT THIS IS, FIRST, AND WHAT "CHAPTER" MEANS
//           // (2026-09-27). Kept for revert: `t.journeyMapIntro`.
//           intro: hi
//               ? t.journeyMapIntro
//               : 'We split trying for a baby into five parts, called '
//                   'chapters. The middle three come round again every '
//                   "cycle, from one period to the next. That's normal, "
//                   "and it isn't a step backwards. Tap a chapter to "
//                   'read about it.',
//           children: [
//             ttcToolPad(Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 22),
//
//                 // ---- the chapter trail ------------------------------------
//                 //
//                 // ⚠️ THE REPEAT IS DRAWN, NOT ONLY WRITTEN (2026-09-27).
//                 // Chapters two to four sat on one straight line from 1 to 5,
//                 // so each new period looked like walking backwards, and the
//                 // small grey "comes round" label was easy to miss. They now
//                 // sit inside one loop, headed and closed by a line that says
//                 // they repeat. Kept for revert:
//                 //   for (final chapter in TtcChapter.values)
//                 //     _ChapterNode(chapter: chapter,
//                 //         current: chapter == current,
//                 //         last: chapter == TtcChapter.values.last, t: t),
//                 _ChapterNode(
//                   chapter: TtcChapter.preparingTogether,
//                   current: TtcChapter.preparingTogether == current,
//                   last: false,
//                   t: t,
//                 ),
//                 _CycleLoop(
//                   children: [
//                     for (final chapter in const [
//                       TtcChapter.knowingYourRhythm,
//                       TtcChapter.tryingTogether,
//                       TtcChapter.theWaitingDays,
//                     ])
//                       _ChapterNode(
//                         chapter: chapter,
//                         current: chapter == current,
//                         last: chapter == TtcChapter.theWaitingDays,
//                         t: t,
//                         inLoop: true,
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//                 _ChapterNode(
//                   chapter: TtcChapter.aNewBeginning,
//                   current: TtcChapter.aNewBeginning == current,
//                   last: true,
//                   t: t,
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // ---- what they have done ----------------------------------
//                 // ⚠️ NO BIG ZERO (2026-09-27). A large "0" on day one read as
//                 // a score. The count shows only once there is something to
//                 // count. Kept for revert: the trailing count, always.
//                 ttcSectionTitle(t.milestones,
//                     trailing: achieved.isEmpty
//                         ? null
//                         : Text('${achieved.length}',
//                             style: ttcJakarta(16, color: ttcPurple))),
//                 if (achieved.isEmpty)
//                   TtcCard(
//                     color: ttcPanel,
//                     child: Text(t.milestonesNone, style: ttcBody(13.5, h: 1.5)),
//                   )
//                 else
//                   for (final m in achieved) ...[
//                     _MilestoneCard(milestone: m, done: true, t: t),
//                     const SizedBox(height: 10),
//                   ],
//
//                 if (ahead.isNotEmpty) ...[
//                   const SizedBox(height: 20),
//                   // "Still ahead", never "missing" and never a count of what is
//                   // undone. Warm language is a contract.
//                   ttcSectionTitle(t.milestonesAhead),
//                   for (final m in ahead) ...[
//                     _MilestoneCard(milestone: m, done: false, t: t),
//                     const SizedBox(height: 10),
//                   ],
//                 ],
//
//                 const SizedBox(height: 18),
//                 TtcCard(
//                   onTap: () => openTtcTimeline(context),
//                   child: Row(children: [
//                     const Icon(Icons.timeline_rounded, size: 19, color: ttcPurple),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(t.familyTimeline, style: ttcJakarta(15.5)),
//                             const SizedBox(height: 3),
//                             Text(
//                                 hi
//                                     ? 'Poori kahani, ek jagah'
//                                     : 'The whole story, in one place',
//                                 style: ttcBody(12.5)),
//                           ]),
//                     ),
//                     const Icon(Icons.arrow_forward_rounded,
//                         size: 17, color: ttcMuted),
//                   ]),
//                 ),
//                 const SizedBox(height: 26),
//               ],
//             )),
//           ],
//           // Kept for revert (2026-09-27): the old page's closing.
//           //     ],
//           //   ),
//           // ),
//         );
//       },
//     );
//   }
// }
//
// class _ChapterNode extends StatelessWidget {
//   const _ChapterNode({
//     required this.chapter,
//     required this.current,
//     required this.last,
//     required this.t,
//     this.inLoop = false,
//   });
//
//   final TtcChapter chapter;
//   final bool current;
//   final bool last;
//   final TtcS t;
//
//   /// Drawn inside [_CycleLoop], which says "repeats" once for all three.
//   final bool inLoop;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     // Chapters 2-4 loop. Marked as such rather than drawn as a line, so nobody
//     // reads a repeat as going backwards.
//     final loops = chapter == TtcChapter.knowingYourRhythm ||
//         chapter == TtcChapter.tryingTogether ||
//         chapter == TtcChapter.theWaitingDays;
//
//     return IntrinsicHeight(
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // The trail itself.
//         Column(children: [
//           Container(
//             width: 26,
//             height: 26,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: current ? ttcPurple : Colors.white,
//               shape: BoxShape.circle,
//               border: Border.all(
//                   color: current ? ttcPurple : ttcBorder, width: 2),
//             ),
//             child: current
//                 ? const Icon(Icons.circle, size: 8, color: Colors.white)
//                 : Text('${chapter.number}',
//                     style: ttcBody(11, color: ttcMuted, w: FontWeight.w800)),
//           ),
//           if (!last)
//             Expanded(
//               child: Container(width: 2, color: ttcLine),
//             ),
//         ]),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Padding(
//             padding: EdgeInsets.only(bottom: last ? 0 : 14),
//             child: TtcCard(
//               onTap: () => openTtcChapter(context, chapter),
//               padding: const EdgeInsets.all(16),
//               color: current ? ttcPanel : Colors.white,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(children: [
//                       Expanded(
//                           child: Text(chapter.title(hi), style: ttcJakarta(15.5))),
//                       if (current)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 9, vertical: 4),
//                           decoration: BoxDecoration(
//                               color: ttcPurple,
//                               borderRadius: BorderRadius.circular(999)),
//                           child: Text(t.chapterYouAreHere,
//                               style: ttcBody(9.5,
//                                   color: Colors.white, w: FontWeight.w800)),
//                         ),
//                     ]),
//                     const SizedBox(height: 6),
//                     // ⚠️ WHAT PART OF THE MONTH, NOT A THEME (2026-09-27).
//                     // "Connection and timing" said what the chapter is about;
//                     // she needed which days it is. The stage's one wording.
//                     // Kept for revert: Text(chapter.focus(hi), ...).
//                     Text(hi ? chapter.focus(hi) : ttcChapterPlainPart(chapter),
//                         style: ttcBody(12.5, h: 1.45)),
//
//                     // What brings this chapter. The map showed five names and
//                     // never said what moved anyone between them, so "Preparing
//                     // Together" for twenty-eight days read as the app having
//                     // stopped rather than as a stretch with an end.
//                     //
//                     // Same copy the Today hero uses, so the two cannot drift.
//                     // ⚠️ ON EVERY CARD (2026-09-27), so each one says how she
//                     // moves on from it, not only the one she is in. Kept for
//                     // revert: `if (current) ...[`.
//                     const SizedBox(height: 8),
//                     Text(chapter.nextUp(hi),
//                         style: ttcBody(11.5,
//                             color: current ? ttcPurple : ttcMuted, h: 1.45)),
//                     // The loop box says this once for all three now.
//                     if (loops && !inLoop) ...[
//                       const SizedBox(height: 8),
//                       Row(children: [
//                         const Icon(Icons.loop_rounded, size: 13, color: ttcMuted),
//                         const SizedBox(width: 6),
//                         Text(
//                             hi
//                                 ? 'Har cycle mein dobara aata hai'
//                                 : 'Comes round each cycle',
//                             style: ttcBody(11, color: ttcMuted, w: FontWeight.w600)),
//                       ]),
//                     ],
//                   ]),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _MilestoneCard extends StatelessWidget {
//   const _MilestoneCard({
//     required this.milestone,
//     required this.done,
//     required this.t,
//   });
//
//   final TtcMilestone milestone;
//   final bool done;
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     return TtcCard(
//       padding: const EdgeInsets.all(15),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           width: 36,
//           height: 36,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: done ? ttcPanel : ttcBg,
//             shape: BoxShape.circle,
//             border: done ? null : Border.all(color: ttcLine),
//           ),
//           child: Icon(_icon(milestone.iconKey),
//               size: 17, color: done ? ttcPurple : ttcMuted),
//         ),
//         const SizedBox(width: 13),
//         Expanded(
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(milestone.title(hi),
//                 style: ttcJakarta(14.5,
//                     color: done ? ttcTitleInk : ttcSoft)),
//             const SizedBox(height: 4),
//             Text(milestone.body(hi), style: ttcBody(12.5, h: 1.5)),
//           ]),
//         ),
//         if (done)
//           const Padding(
//             padding: EdgeInsets.only(left: 8, top: 2),
//             child: Icon(Icons.check_circle_rounded, size: 18, color: ttcPurple),
//           ),
//       ]),
//     );
//   }
//
//   IconData _icon(String key) {
//     switch (key) {
//       case 'flag':
//         return Icons.flag_outlined;
//       case 'pill':
//         return Icons.medication_outlined;
//       case 'cycle':
//         return Icons.favorite_outline_rounded;
//       case 'loop':
//         return Icons.loop_rounded;
//       case 'egg':
//         return Icons.egg_outlined;
//       case 'people':
//         return Icons.people_outline_rounded;
//       case 'test':
//         return Icons.biotech_outlined;
//       case 'write':
//         return Icons.edit_outlined;
//       case 'spa':
//         return Icons.spa_outlined;
//       case 'sun':
//         return Icons.wb_sunny_outlined;
//       case 'star':
//         return Icons.auto_awesome_rounded;
//       default:
//         return Icons.circle_outlined;
//     }
//   }
// }
//
// /// Chapters two to four, drawn as the loop they are: a soft box headed by
// /// what repeats and closed by what starts it again. English only (new copy).
// class _CycleLoop extends StatelessWidget {
//   const _CycleLoop({required this.children});
//
//   final List<Widget> children;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       key: const ValueKey('ttc_map_cycle_loop'),
//       padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
//       decoration: BoxDecoration(
//         color: ttcPanel.withValues(alpha: 0.45),
//         borderRadius: BorderRadius.circular(ttcCardRadius),
//         border: Border.all(color: ttcLine, width: 1.5),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           const Icon(Icons.loop_rounded, size: 16, color: ttcPurple),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text('These three repeat every cycle',
//                 style: ttcBody(12, color: ttcPurple, w: FontWeight.w800)),
//           ),
//         ]),
//         const SizedBox(height: 12),
//         ...children,
//         const SizedBox(height: 10),
//         Row(children: [
//           const Icon(Icons.u_turn_left_rounded, size: 16, color: ttcMuted),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text('A new period starts the loop again',
//                 style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
//           ),
//         ]),
//       ]),
//     );
//   }
// }
