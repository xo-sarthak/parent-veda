// =============================================================================
//  Family Timeline
// -----------------------------------------------------------------------------
//  One continuous life story - the feature the master document names as the one
//  it thinks is missing (p.117).
//
//  The design rule that makes it work: it is grouped by YEAR, not by stage.
//  Grouping by stage would draw exactly the boundary the whole product exists
//  to remove - "here is your TTC section, here is your pregnancy section". A
//  family does not experience their life in product modules. The stage is a
//  small tag on each row, nothing more.
//
//  It lives in the TTC module today because TTC is the first stage to write to
//  it, but FamilyTimeline itself belongs to no stage - pregnancy and parenting
//  backfill into the same log later without this screen changing.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT ON THE TOOL SHELL, AS A TRAIL (tool rebuild, 2026-09-27, night)
//  ---------------------------------------------------------------------------
//  It was the last page in this family still on the V1 plain page with a back
//  bar, a stack of shadowed cards with violet icons that did nothing on a tap.
//  Now it wears the same shell as the Journey map that opens it, and each
//  moment sits on a hairline rail with its date above it (Bumble "Your
//  report", https://mobbin.com/screens/09426d05-9e3c-4a74-b206-da7d04e07ba4).
//  A moment the milestone engine wrote opens where it lives (a journal entry
//  opens the journal); one with nowhere to go does not pretend to.
//
//  ⚠️ A PROMISE THAT WAS ONLY TRUE AFTER VISITING ANOTHER SCREEN. The empty
//  state said a journal entry or a logged period "show up here". They only did
//  once the Journey map had been opened, because the map is what copies
//  reached milestones in (`TtcMilestoneEngine.syncToTimeline`). This page now
//  runs the same idempotent copy when it opens, so what it promises is true
//  whichever way she arrives (the calendar links here too).
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/family_timeline.dart';
import '../../services/life_stage_store.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_milestones.dart';
import '../doors/pv_list_row.dart' show PvRowGroup;
import '../v2/v2_palette.dart';
import 'ttc_journal_screen.dart' show openTtcJournal;
import 'ttc_journey_map_screen.dart' show ttcTimelineSurface;
import 'ttc_lookup_parts.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart' show openTtcSurface;
import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_tool_chrome.dart';
import 'ttc_tool_hues.dart';

void openTtcTimeline(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcTimelineScreen(),
    settings: const RouteSettings(name: 'ttc/timeline'),
  ));
}

class TtcTimelineScreen extends StatefulWidget {
  const TtcTimelineScreen({super.key});

  @override
  State<TtcTimelineScreen> createState() => _TtcTimelineScreenState();
}

class _TtcTimelineScreenState extends State<TtcTimelineScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame, not during build: it may add rows, and adding
    // notifies the builder below.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) const TtcMilestoneEngine().syncToTimeline();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([FamilyTimeline.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final p = V2PaletteStore.instance.current;
        final events = FamilyTimeline.instance.events;

        // Grouped by year. A life story reads in years, not in modules.
        final byYear = <int, List<TimelineEvent>>{};
        for (final e in events) {
          byYear.putIfAbsent(e.date.year, () => []).add(e);
        }
        final years = byYear.keys.toList()..sort();
        // ⚠️ THE STAGE TAG ONLY WHEN IT TELLS HER SOMETHING (2026-09-27).
        // While every row is from one stage, "TRYING TO CONCEIVE" on each of
        // them repeats what she knows. It comes back the day a second stage
        // writes here, which is when it starts to mean something.
        final oneStage = events.map((e) => e.stage).toSet().length <= 1;

        final ways = PvRowGroup(p: p, children: [
          TtcLookupActionRow(
            key: const ValueKey('ttc_timeline_write'),
            icon: Icons.edit_outlined,
            label: 'Write in the journal',
            onTap: () => openTtcJournal(context),
          ),
          TtcLookupActionRow(
            key: const ValueKey('ttc_timeline_log_period'),
            icon: Icons.water_drop_outlined,
            label: 'Log a period',
            onTap: () => logTtcPeriod(context),
          ),
        ]);

        // Kept for revert (2026-09-27, night): a plain Scaffold with
        // `TtcBackBar(title: t.familyTimeline)` and a ListView of cards.
        return TtcToolScaffold(
          // T6 (2026-09-28): the Journey map's group colour, named. Kept for
          // revert: hue: 104,
          hue: kTtcToolHuePlan,
          eyebrow: hi ? t.familyTimeline : 'Family timeline',
          title: 'Your story, in date order.',
          // What this is, first (2026-09-27). Kept for revert:
          //   Text(t.familyTimelineIntro, ...)
          intro: hi
              ? t.familyTimelineIntro
              : 'Everything you log, write and reach, in date order. '
                  'It keeps going into pregnancy and parenting, so '
                  'nothing starts over.',
          variant: 3,
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ⚠️ THE EMPTY STATE NAMES WHERE THE FIRST ENTRY COMES FROM,
                // AND OFFERS BOTH (2026-09-27). Nothing can be added here
                // directly; it fills from the journal and the cycle log.
                if (events.isEmpty) ...[
                  const SizedBox(height: 24),
                  Text(t.timelineEmptyTitle, style: ttcLookupTitle(p)),
                  const SizedBox(height: 6),
                  Text(
                      hi
                          ? t.timelineEmptyBody
                          : 'This fills by itself. A journal entry, a period '
                              'you log and each milestone you reach show up '
                              'here in order, and stay through pregnancy and '
                              'parenting.',
                      style: ttcLookupBody(p)),
                  const SizedBox(height: 12),
                  ways,
                ] else ...[
                  for (final year in years) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 22, bottom: 12),
                      // 24 -> 19 (2026-09-27): a huge year over two rows in
                      // the first months outweighed the rows themselves.
                      child: Text('$year',
                          style: pvFraunces(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: p.ink1)),
                    ),
                    for (var i = 0; i < byYear[year]!.length; i++)
                      _EventStep(
                        event: byYear[year]![i],
                        t: t,
                        showStage: !oneStage,
                        last: i == byYear[year]!.length - 1,
                      ),
                  ],
                  // A way to add to the story, always, not only when empty.
                  const TtcLookupHeading('Add to your story', top: 26),
                  ways,
                ],
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }
}

/// One moment on the rail: its date, a dot, the title and the detail. Opens
/// where it lives when it lives somewhere.
class _EventStep extends StatelessWidget {
  const _EventStep({
    required this.event,
    required this.t,
    required this.last,
    this.showStage = true,
  });

  final TimelineEvent event;
  final TtcS t;
  final bool last;

  /// False while every event is from one stage (see the note in build).
  final bool showStage;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final p = V2PaletteStore.instance.current;
    final detail = event.detail(hi);
    final surface = ttcTimelineSurface(event.id);
    final body = IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 20,
          child: Column(children: [
            const SizedBox(height: 4),
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: event.kind == TimelineKind.milestone
                    ? p.ink1
                    : p.surface,
                shape: BoxShape.circle,
                border: Border.all(color: p.ink1, width: 1.5),
              ),
            ),
            if (!last) Expanded(child: Container(width: 1.5, color: p.line)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 4 : 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fmt(event.date).toUpperCase(),
                      style: pvManrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: p.ink3)),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Text(event.title(hi),
                          style: pvManrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                              color: p.ink1)),
                    ),
                    if (surface != null)
                      Icon(Icons.chevron_right_rounded,
                          size: 20, color: p.ink3),
                  ]),
                  if (detail != null) ...[
                    const SizedBox(height: 4),
                    Text(detail,
                        style: pvManrope(
                            fontSize: 13, height: 1.5, color: p.ink2)),
                  ],
                  // The stage is a small tag, never a section heading.
                  if (showStage) ...[
                    const SizedBox(height: 6),
                    Text(event.stage.label(hi).toUpperCase(),
                        style: pvManrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: p.ink3)),
                  ],
                ]),
          ),
        ),
      ]),
    );
    if (surface == null) return body;
    return InkWell(
      key: ValueKey('ttc_timeline_event_${event.id}'),
      onTap: () => openTtcSurface(context, surface),
      borderRadius: BorderRadius.circular(12),
      child: body,
    );
  }

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }
}

// =============================================================================
//  Kept for revert (2026-09-27, night): the page, the event card and the
//  start row as they were before the tool rebuild.
// =============================================================================
// class TtcTimelineScreen extends StatelessWidget {
//   const TtcTimelineScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([FamilyTimeline.instance, TtcLang.instance]),
//       builder: (context, _) {
//         final t = TtcS.current();
//         final events = FamilyTimeline.instance.events;
//
//         // Grouped by year. A life story reads in years, not in modules.
//         final byYear = <int, List<TimelineEvent>>{};
//         for (final e in events) {
//           byYear.putIfAbsent(e.date.year, () => []).add(e);
//         }
//         final years = byYear.keys.toList()..sort();
//         // ⚠️ THE STAGE TAG ONLY WHEN IT TELLS HER SOMETHING (2026-09-27).
//         // While every row is from one stage, "TRYING TO CONCEIVE" on each of
//         // them repeats what she knows. It comes back the day a second stage
//         // writes here, which is when it starts to mean something.
//         final oneStage = events.map((e) => e.stage).toSet().length <= 1;
//
//         return Scaffold(
//           backgroundColor: ttcBg,
//           body: SafeArea(
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(
//                   ttcGutter, 8, ttcGutter, ttcBottomInset),
//               children: [
//                 TtcBackBar(title: t.familyTimeline),
//                 const SizedBox(height: 16),
//                 // What this is, first (2026-09-27). Kept for revert:
//                 //   Text(t.familyTimelineIntro, ...)
//                 Text(
//                     t.hinglish
//                         ? t.familyTimelineIntro
//                         : 'Everything you log, write and reach, in date order. '
//                             'It keeps going into pregnancy and parenting, so '
//                             'nothing starts over.',
//                     style: ttcBody(13.5, h: 1.6)),
//                 const SizedBox(height: 20),
//
//                 // ⚠️ THE EMPTY STATE NAMES WHERE THE FIRST ENTRY COMES FROM,
//                 // AND OFFERS BOTH (2026-09-27). Nothing can be added here
//                 // directly; it fills from the journal and the cycle log, and
//                 // the empty card used to say "as you log" without saying
//                 // where. Kept for revert: the TtcEmpty alone.
//                 if (events.isEmpty) ...[
//                   TtcEmpty(
//                     icon: Icons.timeline_rounded,
//                     title: t.timelineEmptyTitle,
//                     body: t.hinglish
//                         ? t.timelineEmptyBody
//                         : 'This fills by itself. A journal entry, a period you '
//                             'log and each milestone you reach show up here in '
//                             'order, and stay through pregnancy and parenting.',
//                   ),
//                   const SizedBox(height: 12),
//                   _StartRow(
//                     key: const ValueKey('ttc_timeline_write'),
//                     icon: Icons.edit_outlined,
//                     label: 'Write in the journal',
//                     onTap: () => openTtcJournal(context),
//                   ),
//                   const SizedBox(height: 10),
//                   _StartRow(
//                     key: const ValueKey('ttc_timeline_log_period'),
//                     icon: Icons.water_drop_outlined,
//                     label: 'Log a period',
//                     onTap: () => logTtcPeriod(context),
//                   ),
//                 ] else
//                   for (final year in years) ...[
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 12, top: 4),
//                       // 24 -> 19 (2026-09-27): a huge year over two rows in
//                       // the first months outweighed the rows themselves.
//                       child: Text('$year',
//                           style: ttcFraunces(19,
//                               w: FontWeight.w600, color: ttcTitleInk)),
//                     ),
//                     for (final e in byYear[year]!) ...[
//                       _EventRow(event: e, t: t, showStage: !oneStage),
//                       const SizedBox(height: 10),
//                     ],
//                     const SizedBox(height: 14),
//                   ],
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _EventRow extends StatelessWidget {
//   const _EventRow({
//     required this.event,
//     required this.t,
//     this.showStage = true,
//   });
//
//   final TimelineEvent event;
//   final TtcS t;
//
//   /// False while every event is from one stage (see the note in build).
//   final bool showStage;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     final detail = event.detail(hi);
//     return TtcCard(
//       padding: const EdgeInsets.all(15),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           width: 34,
//           height: 34,
//           alignment: Alignment.center,
//           decoration: const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
//           child: Icon(_icon(event.kind), size: 16, color: ttcPurple),
//         ),
//         const SizedBox(width: 13),
//         Expanded(
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Expanded(
//                   child: Text(event.title(hi), style: ttcJakarta(14.5))),
//               Text(_fmt(event.date),
//                   style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
//             ]),
//             if (detail != null) ...[
//               const SizedBox(height: 5),
//               Text(detail, style: ttcBody(12.5, h: 1.5)),
//             ],
//             // The stage is a small tag, never a section heading.
//             if (showStage) ...[
//               const SizedBox(height: 7),
//               Text(event.stage.label(hi).toUpperCase(),
//                   style: ttcBody(9, color: ttcMuted, w: FontWeight.w800)),
//             ],
//           ]),
//         ),
//       ]),
//     );
//   }
//
//   IconData _icon(TimelineKind kind) {
//     switch (kind) {
//       case TimelineKind.milestone:
//         return Icons.auto_awesome_rounded;
//       case TimelineKind.medical:
//         return Icons.medical_services_outlined;
//       case TimelineKind.written:
//         return Icons.edit_outlined;
//       case TimelineKind.people:
//         return Icons.people_outline_rounded;
//       case TimelineKind.action:
//         return Icons.check_circle_outline_rounded;
//     }
//   }
//
//   static String _fmt(DateTime d) {
//     const m = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//     ];
//     return '${d.day} ${m[d.month - 1]}';
//   }
// }
//
// /// One way to make the first entry, from the empty timeline.
// class _StartRow extends StatelessWidget {
//   const _StartRow({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) => TtcCard(
//         onTap: onTap,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(children: [
//           Icon(icon, size: 18, color: ttcPurple),
//           const SizedBox(width: 12),
//           Expanded(child: Text(label, style: ttcJakarta(14.5))),
//           const Icon(Icons.arrow_forward_rounded, size: 16, color: ttcMuted),
//         ]),
//       );
// }
